import Foundation
import SourceKittenFramework

struct XMASSwiftParser {
    let protocolDeclKind   : String = "source.lang.swift.decl.protocol"
    let structDeclKind     : String = "source.lang.swift.decl.struct"
    let instanceVarKind    : String = "source.lang.swift.decl.var.instance"
    let staticVarKind      : String = "source.lang.swift.decl.var.static"
    let instanceMethodKind : String = "source.lang.swift.decl.function.method.instance"
    let staticMethodKind   : String = "source.lang.swift.decl.function.method.static"
    let mutableMethodKind  : String = "source.decl.attribute.mutating"

    // MARK: Structs
    func parseStructDeclaration(_ dict: [String: SourceKitRepresentable], filePath: String) throws -> StructDeclaration? {
        guard let kind = dict["key.kind"] as? String else {
            return nil
        }
        if kind != structDeclKind {
            return nil
        }

        let structName = dict["key.name"] as! String
        let fields : [String] = findFieldsInStructDeclaration(dict)
        let range = NSMakeRange(
            Int.init(truncatingBitPattern: dict["key.offset"] as! Int64),
            Int.init(truncatingBitPattern: dict["key.length"] as! Int64)
        )

        return StructDeclaration.init(
            name: structName,
            range: range,
            filePath: filePath,
            fields: fields
        )
    }

    func findFieldsInStructDeclaration(_ dict: [String: SourceKitRepresentable]) -> [String] {
        var fields : [String] = []

        guard let fileSubStructure = dict["key.substructure"] as? [SourceKitRepresentable] else {
            return fields
        }

        for item in fileSubStructure {
            if let child = item as? [String: SourceKitRepresentable] {
                guard let kind = child["key.kind"] as? String else {
                    continue
                }
                if kind != instanceVarKind {
                    continue
                }

                fields.append(child["key.name"] as! String)
            }
        }

        return fields
    }

    // MARK: Protocols
    func parseProtocolDeclaration(_ dict: [String: SourceKitRepresentable], filePath: String) throws -> ProtocolDeclaration? {
        var fileContents : NSString
        try fileContents = NSString.init(contentsOfFile: filePath, encoding:String.Encoding.utf8.rawValue)

        guard let kind = dict["key.kind"] as? String else {
            return nil
        }
        if kind != protocolDeclKind {
            return nil
        }

        let protocolName = dict["key.name"] as! String
        let inheritedProtocols = inheritedTypesForProtocol(dict)

        let protocolRange = NSMakeRange(
            Int.init(truncatingBitPattern: dict["key.offset"] as! Int64),
            Int.init(truncatingBitPattern: dict["key.length"] as! Int64)
        )

        /*

        TODO (unimplemented features) notes :

        initializers : instance.method where method name starts with init
        seems to lose type information? (swiftc dump-ast still has it tho!)

        (pretty shitty, we seem to lose information about whether these are just GET or SET or GET + Set)

        subscript anything -> TOTALLY UNAVAILABLE
        */

        let usesTypeAlias = findTypealiasInProtocolDecl(dict, fileContents: fileContents)
        let (getters, setters) = accessorsFromProtocolDecl(dict, kind: instanceVarKind)
        let (staticGetters, staticSetters) = accessorsFromProtocolDecl(dict, kind: staticVarKind)
        let methods = methodsFromProtocolDecl(dict, fileContents: fileContents)
        let instanceMethods = methods.instanceM
        let staticMethods = methods.staticM
        let mutatingMethods = methods.mutableM

        return ProtocolDeclaration.init(
            name: protocolName,
            containingFile: filePath,
            rangeInFile: protocolRange,
            usesTypealias: usesTypeAlias,
            includedProtocols: inheritedProtocols,
            instanceMethods: instanceMethods,
            staticMethods: staticMethods,
            mutatingMethods: mutatingMethods,
            initializers: [],
            getters: getters,
            setters: setters,
            staticGetters: staticGetters,
            staticSetters: staticSetters,
            subscriptGetters: [],
            subscriptSetters: []
        )
    }

    // mark - Private

    func accessorsFromProtocolDecl(_ protocolDict : [String: SourceKitRepresentable], kind : String) -> (Array<Accessor>, Array<Accessor>) {
        var getters : Array<Accessor> = []
        var setters : Array<Accessor> = []

        guard let fileSubStructure = protocolDict["key.substructure"] as? [SourceKitRepresentable] else {
            return (getters, setters)
        }

        for item in fileSubStructure {
            if let protocolDict = item as? [String: SourceKitRepresentable] {
                if protocolDict["key.kind"] == nil || !protocolDict["key.kind"]!.isEqualTo(kind) {
                    continue
                }

                let accessor = Accessor.init(
                    name: protocolDict["key.name"] as! String,
                    returnType: protocolDict["key.typename"] as! String
                )

                let accessibility : SourceKitRepresentable? = protocolDict["key.setter_accessibility"]
                if let _ = accessibility as? String {
                    setters.append(accessor)
                } else {
                    getters.append(accessor)
                }
            }
        }

        return (getters, setters)
    }

    typealias MethodDecls = (
        instanceM: [MethodDeclaration],
        staticM: [MethodDeclaration],
        mutableM: [MethodDeclaration]
    )

    func methodsFromProtocolDecl(_ protocolDict: [String: SourceKitRepresentable], fileContents : NSString) -> MethodDecls {
        var instanceMethods : Array<MethodDeclaration> = []
        var staticMethods : Array<MethodDeclaration> = []
        var mutableMethods : Array<MethodDeclaration> = []

        guard let substructure = protocolDict["key.substructure"] as? [SourceKitRepresentable] else {
            return (instanceM: instanceMethods, staticM: staticMethods, mutableM: mutableMethods)
        }

        for item in substructure {
            if let protocolBodyItem = item as? [String: SourceKitRepresentable] {
                guard let kind = protocolBodyItem["key.kind"] as? String else {
                    continue
                }

                let isInstanceMethod = kind == instanceMethodKind
                let isStaticMethod = kind == staticMethodKind
                let isMutableMethod = hasMatchingAttribute(protocolBodyItem, attributeName: mutableMethodKind)
                if  !isInstanceMethod && !isStaticMethod {
                    continue
                }

                let methodDeclaration = MethodDeclaration.init(
                    name: methodNameFromMethodDict(protocolBodyItem),
                    throwsError: methodCanThrowError(protocolBodyItem, fileContents: fileContents),
                    arguments: argumentsFromMethodDict(protocolBodyItem),
                    returnValueTypes: returnTypesFromMethodDict(protocolBodyItem, fileContents: fileContents)
                )

                // initializers are not supported right now
                if methodDeclaration.name.hasPrefix("init") {
                    continue
                }

                if isMutableMethod {
                    mutableMethods.append(methodDeclaration)
                }
                else if isInstanceMethod {
                    instanceMethods.append(methodDeclaration)
                } else {
                    staticMethods.append(methodDeclaration)
                }
            }
        }

        return (instanceM: instanceMethods, staticM: staticMethods, mutableM: mutableMethods)
    }

    func hasMatchingAttribute(_ protocolBodyItem : [String: SourceKitRepresentable], attributeName: String) -> Bool {
        if let attributes = protocolBodyItem["key.attributes"] as? [SourceKitRepresentable] {
            for attribute : SourceKitRepresentable in attributes {
                if let attrs = attribute as? [String: SourceKitRepresentable] {
                    guard let attrsString = attrs["key.attribute"] as? String else {
                        continue
                    }

                    if attrsString == attributeName {
                        return true
                    }
                }
            }
        }

        return false
    }

    func methodNameFromMethodDict(_ protocolBodyItem : [String: SourceKitRepresentable]) -> String {
        let methodName = protocolBodyItem["key.name"] as! String
        let regex : NSRegularExpression
        try! regex = NSRegularExpression(pattern: "\\(.*\\)", options: .caseInsensitive)

        return regex.stringByReplacingMatches(
            in: methodName,
            options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
            range: NSRange(0..<methodName.utf16.count),
            withTemplate: ""
        )
    }

    func argumentsFromMethodDict(_ dict : [String: SourceKitRepresentable]) -> Array<MethodParameter> {
        var parameters : Array<MethodParameter> = []

        guard let substructure = dict["key.substructure"] as? [SourceKitRepresentable] else {
            return parameters
        }

        for item in substructure {
            let innerDict : [String: SourceKitRepresentable] = item as! [String: SourceKitRepresentable]
            if innerDict["key.kind"] as! String != "source.lang.swift.decl.var.parameter" {
                continue
            }

            parameters.append(MethodParameter.init(
                name: innerDict["key.name"] as! String,
                type: innerDict["key.typename"] as! String
                ))
        }

        return parameters
    }

    func returnTypesFromMethodDict(_ dict : [String: SourceKitRepresentable], fileContents : NSString) -> Array<ReturnType> {
        var types : Array<ReturnType> = []
        var regex : NSRegularExpression
        try! regex = NSRegularExpression(pattern: ".*\\s+->\\s+\\(?([^\\)]*)\\)?", options: NSRegularExpression.Options.caseInsensitive)

        let start = Int(truncatingBitPattern: dict["key.offset"] as! Int64)
        let length = Int(truncatingBitPattern: dict["key.length"] as! Int64)

        let funcDeclarationString = utf8Substring(string: fileContents, start: start, length: length)

        let matches = regex.matches(
            in: funcDeclarationString,
            options: NSRegularExpression.MatchingOptions.anchored,
            range: NSRange(0..<funcDeclarationString.utf16.count)
        )

        let whitespace : CharacterSet = CharacterSet(charactersIn: " \t")
        for match : NSTextCheckingResult in matches {
            let substring : String = (funcDeclarationString as NSString).substring(with: match.rangeAt(1))
            let components : [String] = substring.components(separatedBy: ",")
            for type in components {
                types.append(type.trimmingCharacters(in: whitespace))
            }
        }

        return types
    }

    func methodCanThrowError(_ methodItem : [String: SourceKitRepresentable], fileContents: NSString) -> Bool {
        var regex : NSRegularExpression
        try! regex = NSRegularExpression(pattern: ".*\\)\\sthrows\\s", options: NSRegularExpression.Options.caseInsensitive)

        let startOfMethodDecl = Int(truncatingBitPattern: methodItem["key.offset"] as! Int64)
        let lengthOfMethodDecl = Int(truncatingBitPattern: methodItem["key.length"] as! Int64)
        let endOfMethodDecl = startOfMethodDecl + lengthOfMethodDecl

        let utf8FileContents = String(fileContents).utf8

        let utf8StartIndex = utf8FileContents.index(utf8FileContents.startIndex, offsetBy: startOfMethodDecl)
        let utf8EndIndex = utf8FileContents.index(utf8StartIndex, offsetBy: lengthOfMethodDecl)

        let stringFileContents = String(fileContents)

        guard let characterStartIndex = String.Index(utf8StartIndex, within: stringFileContents),
            let characterEndIndex = String.Index(utf8EndIndex, within: stringFileContents) else {
                return false
        }

        let rangeLocation = stringFileContents.distance(from: stringFileContents.startIndex, to: characterStartIndex)
        let rangeEnd = stringFileContents.distance(from: stringFileContents.startIndex, to: characterEndIndex)

        let rangeOfFileAfterMethodDecl = NSRange(location: rangeLocation, length: fileContents.length - rangeEnd)
        var indexOfNextNewline = fileContents.range(of: "\n", options: NSString.CompareOptions.literal, range: rangeOfFileAfterMethodDecl).location


        if indexOfNextNewline == NSNotFound {
            indexOfNextNewline = endOfMethodDecl
        }

        let utf8IndexOfNextNewline = String.UTF8View.Index(stringFileContents.index(stringFileContents.startIndex, offsetBy: indexOfNextNewline), within: utf8FileContents)
        let distanceToNextNewline = utf8FileContents.distance(from: utf8FileContents.startIndex, to: utf8IndexOfNextNewline)

        let lengthOfMethodDeclIncludingNewline = distanceToNextNewline - startOfMethodDecl + 1


        let funcDeclarationString = utf8Substring(
            string: fileContents,
            start: startOfMethodDecl,
            length: lengthOfMethodDeclIncludingNewline
        )

        let numberOfMatches = regex.numberOfMatches(
            in: funcDeclarationString,
            options: NSRegularExpression.MatchingOptions.anchored,
            range: NSRange(location: 0, length: funcDeclarationString.characters.count)
        )

        return numberOfMatches > 0
    }

    func findTypealiasInProtocolDecl(_ protocolBody: [String: SourceKitRepresentable], fileContents: NSString) -> Bool {
        let startOfProtocolBody = Int(truncatingBitPattern: protocolBody["key.bodyoffset"] as! Int64)
        let lengthOfProtocolBody = Int(truncatingBitPattern: protocolBody["key.bodylength"] as! Int64)

        let protocolString = utf8Substring(
            string: fileContents,
            start: startOfProtocolBody,
            length: lengthOfProtocolBody
        )

        var regex : NSRegularExpression
        try! regex = NSRegularExpression(pattern: "\\stypealias\\s", options: NSRegularExpression.Options.anchorsMatchLines)

        let rangeOfString = NSRange(location: 0, length: protocolString.characters.count)
        let matches = regex.matches(in: protocolString, options: [], range: rangeOfString)
        return matches.count > 0
    }

    func inheritedTypesForProtocol(_ protocolDict: [String: SourceKitRepresentable]) -> Array<String> {
        var inheritedProtocols : [String] = []
        guard let inheritedTypes = protocolDict["key.inheritedtypes"] as? [SourceKitRepresentable] else {
            return inheritedProtocols
        }

        for type in inheritedTypes {
            guard let typedDict = type as? [String: SourceKitRepresentable] else {
                continue
            }

            inheritedProtocols.append(typedDict["key.name"] as! String)
        }

        return inheritedProtocols
    }

    private func utf8Substring(string: NSString, start: Int, length: Int) -> String {
        let utf8String = String(string).utf8

        let startIndex = utf8String.index(utf8String.startIndex, offsetBy: start)
        let endIndex = utf8String.index(startIndex, offsetBy: length)

        let range = startIndex..<endIndex
        return String(describing: utf8String[range])
    }
}

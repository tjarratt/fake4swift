import Foundation
import SwiftXPC
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
    func parseStructDeclaration(dict: [String: SourceKitRepresentable], filePath: String) throws -> StructDeclaration? {
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

    func findFieldsInStructDeclaration(dict: [String: SourceKitRepresentable]) -> [String] {
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
    func parseProtocolDeclaration(dict: [String: SourceKitRepresentable], filePath: String) throws -> ProtocolDeclaration? {
        var fileContents : NSString
        try fileContents = NSString.init(contentsOfFile: filePath, encoding:NSUTF8StringEncoding)

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

    func accessorsFromProtocolDecl(protocolDict : [String: SourceKitRepresentable], kind : String) -> (Array<Accessor>, Array<Accessor>) {
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

    func methodsFromProtocolDecl(protocolDict: [String: SourceKitRepresentable], fileContents : NSString) -> MethodDecls {
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

    func hasMatchingAttribute(protocolBodyItem : [String: SourceKitRepresentable], attributeName: String) -> Bool {
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

    func methodNameFromMethodDict(protocolBodyItem : [String: SourceKitRepresentable]) -> String {
        let methodName : String = protocolBodyItem["key.name"] as! String
        var regex : NSRegularExpression
        try! regex = NSRegularExpression(pattern: "\\(.*\\)", options: NSRegularExpressionOptions.CaseInsensitive)

        return regex.stringByReplacingMatchesInString(
            methodName,
            options: NSMatchingOptions.WithoutAnchoringBounds,
            range: NSRange.init(location: 0, length: methodName.characters.count),
            withTemplate: ""
        )
    }

    func argumentsFromMethodDict(dict : [String: SourceKitRepresentable]) -> Array<MethodParameter> {
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

    func returnTypesFromMethodDict(dict : [String: SourceKitRepresentable], fileContents : NSString) -> Array<ReturnType> {
        var types : Array<ReturnType> = []
        var regex : NSRegularExpression
        try! regex = NSRegularExpression(pattern: ".*\\s+->\\s+\\(?([^\\)]*)\\)?", options: NSRegularExpressionOptions.CaseInsensitive)

        let start : Int = Int.init(truncatingBitPattern: dict["key.offset"] as! Int64)
        let end : Int = Int.init(truncatingBitPattern: dict["key.length"] as! Int64)
        let range = NSMakeRange(start, end)

        let funcDeclarationString = fileContents.substringWithRange(range) as String

        let matches = regex.matchesInString(
            funcDeclarationString,
            options: NSMatchingOptions.Anchored,
            range: NSRange.init(location: 0, length: funcDeclarationString.characters.count)
        )

        let whitespace : NSCharacterSet = NSCharacterSet(charactersInString: " \t")
        for match : NSTextCheckingResult in matches {
            let substring : String = (funcDeclarationString as NSString).substringWithRange(match.rangeAtIndex(1))
            let components : [String] = substring.componentsSeparatedByString(",")
            for type in components {
                types.append(type.stringByTrimmingCharactersInSet(whitespace))
            }
        }

        return types
    }

    func methodCanThrowError(methodItem : [String: SourceKitRepresentable], fileContents: NSString) -> Bool {
        var regex : NSRegularExpression
        try! regex = NSRegularExpression(pattern: ".*\\)\\sthrows\\s", options: NSRegularExpressionOptions.CaseInsensitive)

        let startOfMethodDecl : Int = Int.init(truncatingBitPattern: methodItem["key.offset"] as! Int64)
        let lengthOfMethodDecl : Int = Int.init(truncatingBitPattern: methodItem["key.length"] as! Int64)
        let endOfMethodDecl : Int = startOfMethodDecl + lengthOfMethodDecl

        let rangeOfFileAfterMethodDecl : NSRange = NSRange.init(location: endOfMethodDecl, length: fileContents.length - endOfMethodDecl)
        var indexOfNextNewline : NSInteger = fileContents.rangeOfString("\n", options: NSStringCompareOptions.LiteralSearch, range: rangeOfFileAfterMethodDecl).location

        if indexOfNextNewline == NSNotFound {
            indexOfNextNewline = endOfMethodDecl
        }

        let range = NSMakeRange(startOfMethodDecl, indexOfNextNewline - startOfMethodDecl + 1)
        let funcDeclarationString = fileContents.substringWithRange(range) as String

        let numberOfMatches = regex.numberOfMatchesInString(
            funcDeclarationString,
            options: NSMatchingOptions.Anchored,
            range: NSRange.init(location: 0, length: funcDeclarationString.characters.count)
        )

        return numberOfMatches > 0
    }

    func findTypealiasInProtocolDecl(protocolBody: [String: SourceKitRepresentable], fileContents: NSString) -> Bool {
        // read from body offset - body length
        // regex for " typealias "
        let startOfProtocolBody : Int = Int.init(truncatingBitPattern: protocolBody["key.bodyoffset"] as! Int64)
        let lengthOfProtocolBody : Int = Int.init(truncatingBitPattern: protocolBody["key.bodylength"] as! Int64)
        let range : NSRange = NSRange.init(location: startOfProtocolBody, length: lengthOfProtocolBody)
        let protocolString : String = fileContents.substringWithRange(range)

        var regex : NSRegularExpression
        try! regex = NSRegularExpression(pattern: "\\stypealias\\s", options: NSRegularExpressionOptions.AnchorsMatchLines)

        let rangeOfString : NSRange = NSRange.init(location: 0, length: lengthOfProtocolBody)
        let matches = regex.matchesInString(protocolString, options: NSMatchingOptions.init(rawValue: 0), range: rangeOfString)
        return matches.count > 0
    }

    func inheritedTypesForProtocol(protocolDict: [String: SourceKitRepresentable]) -> Array<String> {
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
}
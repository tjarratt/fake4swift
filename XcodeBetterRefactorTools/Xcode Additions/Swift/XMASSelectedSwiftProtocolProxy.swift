import AppKit
import SwiftXPC
import SourceKittenFramework

let protocolDeclKind   : String = "source.lang.swift.decl.protocol"
let instanceVarKind    : String = "source.lang.swift.decl.var.instance"
let staticVarKind      : String = "source.lang.swift.decl.var.static"
let instanceMethodKind : String = "source.lang.swift.decl.function.method.instance"
let staticMethodKind   : String = "source.lang.swift.decl.function.method.static"
let mutableMethodKind  : String = "source.decl.attribute.mutating"

class XMASSelectedSwiftProtocolProxy: NSObject, XMASSelectedTextProxy {
    var xcodeRepository : XMASXcodeRepository

    init(xcodeRepo : XMASXcodeRepository) {
        xcodeRepository = xcodeRepo
    }

    func selectedProtocolInFile(fileName : String!) -> (ProtocolDeclaration?) {
        let selectedRange : NSRange = xcodeRepository.cursorSelectionRange()

        var fileContents : NSString
        try! fileContents = NSString.init(contentsOfFile: fileName, encoding:NSUTF8StringEncoding)

        let sourceFile = File.init(path: fileName)
        let fileStructure = Structure.init(file: sourceFile!)
        let fileSubStructure : XPCRepresentable = fileStructure.dictionary["key.substructure"]!
        let structureArray = fileSubStructure as! XPCArray

        for item in structureArray {
            if let protocolDict = item as? XPCDictionary {
                if protocolDict["key.kind"]! != protocolDeclKind {
                    continue
                }

                let protocolName = protocolDict["key.name"] as! String

                let protocolRange = NSMakeRange(
                    Int.init(truncatingBitPattern: protocolDict["key.offset"] as! Int64),
                    Int.init(truncatingBitPattern: protocolDict["key.length"] as! Int64)
                )

                /*

                TODO (unimplemented features) notes :

                includedProtocols : look for key.inheritedtypes
                map over key.name to get a string for each protocol type

                initializers : instance.method where method name starts with init
                seems to lose type information? (swiftc dump-ast still has it tho!)

                (pretty shitty, we seem to lose information about whether these are just GET or SET or GET + Set)

                subscript anything -> TOTALLY UNAVAILABLE
                */

                if rangesOverlap(selectedRange, protocolRange: protocolRange) {
                    let (getters, setters) = accessorsFromProtocolDecl(protocolDict, kind: instanceVarKind)
                    let (staticGetters, staticSetters) = accessorsFromProtocolDecl(protocolDict, kind: staticVarKind)
                    let methods = methodsFromProtocolDecl(protocolDict, fileContents: fileContents)
                    let instanceMethods = methods.instanceM
                    let staticMethods = methods.staticM
                    let mutatingMethods = methods.mutableM

                    return ProtocolDeclaration.init(
                        name: protocolName,
                        includedProtocols: [],
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
            }
        }

        return nil
    }

    func rangesOverlap(cursorRange : NSRange, protocolRange : NSRange) -> Bool {
        if cursorRange.location < protocolRange.location {
            return false
        }

        if cursorRange.location > protocolRange.location + protocolRange.length {
            return false
        }

        return true
    }

    func accessorsFromProtocolDecl(protocolDict : XPCDictionary, kind : String) -> (Array<Accessor>, Array<Accessor>) {
        let fileSubStructure : XPCRepresentable = protocolDict["key.substructure"]!
        let structureArray = fileSubStructure as! XPCArray

        var getters : Array<Accessor> = []
        var setters : Array<Accessor> = []

        for item in structureArray {
            if let protocolDict = item as? XPCDictionary {
                if protocolDict["key.kind"]! != kind {
                    continue
                }

                let accessor = Accessor.init(
                    name: protocolDict["key.name"] as! String,
                    returnType: protocolDict["key.typename"] as! String
                )

                let accessibility : XPCRepresentable? = protocolDict["key.setter_accessibility"]
                if let _ = accessibility as? String {
                    setters.append(accessor)
                } else {
                    getters.append(accessor)
                }
            }
        }

        return (getters, setters)
    }

    func methodsFromProtocolDecl(protocolDict: XPCDictionary, fileContents : NSString) -> (instanceM: [MethodDeclaration], staticM: [MethodDeclaration], mutableM: [MethodDeclaration]) {
        var instanceMethods : Array<MethodDeclaration> = []
        var staticMethods : Array<MethodDeclaration> = []
        var mutableMethods : Array<MethodDeclaration> = []
        let subStructure : XPCRepresentable = protocolDict["key.substructure"]!
        let subStructureArray = subStructure as! XPCArray

        for item in subStructureArray {
            if let protocolBodyItem = item as? XPCDictionary {
                let isInstanceMethod = protocolBodyItem["key.kind"]! == instanceMethodKind
                let isStaticMethod = protocolBodyItem["key.kind"]! == staticMethodKind
                let isMutableMethod = hasMatchingAttribute(protocolBodyItem, attributeName: mutableMethodKind)
                if  !isInstanceMethod && !isStaticMethod {
                    continue
                }

                let methodDeclaration = MethodDeclaration.init(
                    name: methodNameFromMethodDict(protocolBodyItem),
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

    func hasMatchingAttribute(protocolBodyItem : XPCDictionary, attributeName: String) -> Bool {
        if let attributes = protocolBodyItem["key.attributes"] as? [XPCRepresentable] {
            for attribute : XPCRepresentable in attributes {
                if let attrs = attribute as? XPCDictionary {
                    if attrs["key.attribute"]! == attributeName {
                        return true
                    }
                }
            }
        }

        return false
    }


    func methodNameFromMethodDict(protocolBodyItem : XPCDictionary) -> String {
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

    func argumentsFromMethodDict(dict : XPCDictionary) -> Array<MethodParameter> {
        let substructure : XPCRepresentable? = dict["key.substructure"]
        if substructure == nil {
            return []
        }

        let substructureArray = substructure as! XPCArray
        var parameters : Array<MethodParameter> = []

        for item in substructureArray {
            let innerDict : XPCDictionary = item as! XPCDictionary
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

    func returnTypesFromMethodDict(dict : XPCDictionary, fileContents : NSString) -> Array<ReturnType> {
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
}

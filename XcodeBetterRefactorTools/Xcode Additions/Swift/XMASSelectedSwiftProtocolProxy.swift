import AppKit
import SwiftXPC
import SourceKittenFramework

let protocolDeclKind   : String = "source.lang.swift.decl.protocol"
let instanceVarKind    : String = "source.lang.swift.decl.var.instance"
let staticVarKind      : String = "source.lang.swift.decl.var.static"
let instanceMethodKind : String = "source.lang.swift.decl.function.method.instance"

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
                    Int.init(truncatingBitPattern: protocolDict["key.nameoffset"] as! Int64),
                    Int.init(truncatingBitPattern: protocolDict["key.namelength"] as! Int64)
                )

                /*

                notes :

                includedProtocols : look for key.inheritedtypes
                map over key.name to get a string for each protocol type

                functions (normal) : just look for key.substructure with decl.function.method.instance as key.kind

                functions (static) : key.kind = source.lang.swift.decl.function.method.static

                functions (mutating) : key.attributes includes {key.name = source.decl.attribute.mutating}

                initializers : instance.method where method name starts with init
                seems to lose type information? (swiftc dump-ast still has it tho!)

                getters : key.kind = source.lang.swift.decl.var.instance
                type info is in key.typename
                setters : key.kind = source.lang.swift.decl.var.instance
                type info is in key.typename

                (pretty shitty, we seem to lose information about whether these are just GET or SET or GET + Set)

                static getters and setters -> key.kind = source.lang.swift.decl.var.static

                subscript anything -> TOTALLY UNAVAILABLE
                */

                if rangesOverlap(selectedRange, protocolRange: protocolRange) {
                    let (getters, setters) = accessorsFromProtocolDecl(protocolDict, kind: instanceVarKind)
                    let (staticGetters, staticSetters) = accessorsFromProtocolDecl(protocolDict, kind: staticVarKind)
                    let funcs = instanceMethodsFromProtocolDecl(protocolDict, fileContents: fileContents)

                    return ProtocolDeclaration.init(
                        name: protocolName,
                        includedProtocols: [],
                        instanceMethods: funcs,
                        staticMethods: [],
                        mutatingMethods: [],
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

    func instanceMethodsFromProtocolDecl(protocolDict: XPCDictionary, fileContents : NSString) -> Array<MethodDeclaration> {
        var methods : Array<MethodDeclaration> = []
        let subStructure : XPCRepresentable = protocolDict["key.substructure"]!
        let subStructureArray = subStructure as! XPCArray

        for item in subStructureArray {
            if let protocolBodyItem = item as? XPCDictionary {
                if protocolBodyItem["key.kind"]! != instanceMethodKind {
                    continue
                }

                // ignores initializers and static methods, which include attributes
                // to be **MORE** correct, we should verify the attributes does not contain
                // the attributes for initializers or static methods
                // unfortunately, the attribute for an initiailizer is "source.decl.attribute.__raw_doc_comment"
                // ... garbage.
                if let _ = protocolBodyItem["key.attributes"] as? XPCArray {
                    continue
                }

                methods.append(MethodDeclaration.init(
                    name: methodNameFromMethodDict(protocolBodyItem),
                    arguments: argumentsFromMethodDict(protocolBodyItem),
                    returnValueTypes: returnTypesFromMethodDict(protocolBodyItem, fileContents: fileContents)
                ))
            }
        }

        return methods
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

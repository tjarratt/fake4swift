import AppKit
import SwiftXPC
import SourceKittenFramework

class XMASSelectedSwiftProtocolProxy: NSObject, XMASSelectedTextProxy {
    var xcodeRepository : XMASXcodeRepository

    init(xcodeRepo : XMASXcodeRepository) {
        xcodeRepository = xcodeRepo
    }

    func selectedProtocolInFile(fileName : String!) -> (ProtocolDeclaration?) {
        let selectedRange : NSRange = xcodeRepository.cursorSelectionRange()

        let sourceFile = File.init(path: fileName)
        let fileStructure = Structure.init(file: sourceFile!)
        let fileSubStructure : XPCRepresentable = fileStructure.dictionary["key.substructure"]!
        let structureArray = fileSubStructure as! XPCArray

        for item in structureArray {
            if let protocolDict = item as? XPCDictionary {
                if protocolDict["key.kind"]! != "source.lang.swift.decl.protocol" {
                    continue
                }

                let protocolName = protocolDict["key.name"] as! String

                NSLog("looking at a protocol '%@' %@", protocolName, protocolDict.description)

                let protocolRange = NSMakeRange(
                    Int.init(truncatingBitPattern: protocolDict["key.nameoffset"] as! Int64),
                    Int.init(truncatingBitPattern: protocolDict["key.namelength"] as! Int64)
                )

                /*

                notes : 
                
                classOnly ? Probably can't get that from sourcekit today (maybe?)
                
                optional methods :  look at key.substructure
                                    look for key.kind = source.lang.swift.decl.function.method.instance
                                    where key.attributes includes key.attribute = source.decl.attribute.optional
                
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
                    let (readonlyAccessors, readWriteAccessors) = accessorsFromProtocolDecl(protocolDict)

                    return ProtocolDeclaration.init(
                        name: protocolName,
                        includedProtocols: [],
                        normalFuncs: [],
                        staticFuncs: [],
                        mutatingFuncs: [],
                        initializers: [],
                        getters: readonlyAccessors,
                        setters: readWriteAccessors,
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

    func accessorsFromProtocolDecl(protocolDict : XPCDictionary) -> (Array<Accessor>, Array<Accessor>) {
        let fileSubStructure : XPCRepresentable = protocolDict["key.substructure"]!
        let structureArray = fileSubStructure as! XPCArray

        var getters : Array<Accessor> = []
        var setters : Array<Accessor> = []

        for item in structureArray {
            if let protocolDict = item as? XPCDictionary {
                if protocolDict["key.kind"]! != "source.lang.swift.decl.var.instance" {
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
}

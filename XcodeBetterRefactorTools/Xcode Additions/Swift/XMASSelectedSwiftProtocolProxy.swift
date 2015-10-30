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
            if let dictValue = item as? XPCDictionary {
                if dictValue["key.kind"]! != "source.lang.swift.decl.protocol" {
                    continue
                }

                let protocolName = dictValue["key.name"] as! String

                NSLog("looking at a protocol '%@' %@", protocolName, dictValue.description)

                let protocolRange = NSMakeRange(
                    Int.init(truncatingBitPattern: dictValue["key.nameoffset"] as! Int64),
                    Int.init(truncatingBitPattern: dictValue["key.namelength"] as! Int64)
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
                    return ProtocolDeclaration.init(
                        name: protocolName,
                        classOnly: false,
                        includedProtocols: [],
                        normalFuncs: [],
                        staticFuncs: [],
                        mutatingFuncs: [],
                        initializers: [],
                        getters: [],
                        setters: [],
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
}

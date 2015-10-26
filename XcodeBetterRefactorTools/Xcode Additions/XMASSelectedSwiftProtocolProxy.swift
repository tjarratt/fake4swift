import AppKit
import SwiftXPC
import SourceKittenFramework

protocol MySpecialProtocol {
    func randomDouble()
}

class XMASSelectedSwiftProtocolProxy: NSObject, XMASSelectedTextProxy {

    func selectedProtocolInFile(fileName : String!) -> String! {
        let xcodeRepository = XMASXcodeRepository.init()
        let editor = xcodeRepository.currentEditor()
        let locations = editor.currentSelectedDocumentLocations()
        let selectedRange = locations.last!.characterRange()

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
                let protocolRange = NSMakeRange(
                    Int.init(truncatingBitPattern: dictValue["key.nameoffset"] as! Int64),
                    Int.init(truncatingBitPattern: dictValue["key.namelength"] as! Int64)
                )

                if rangesOverlap(selectedRange, protocolRange: protocolRange) {
                    return protocolName
                }
            }
        }

        return ""
    }

    func rangesOverlap(cursorRange : NSRange, protocolRange : NSRange) -> Bool {
        if cursorRange.location < protocolRange.location {
            return false
        }

        if protocolRange.location > cursorRange.location + cursorRange.length {
            return false
        }

        return true
    }
}

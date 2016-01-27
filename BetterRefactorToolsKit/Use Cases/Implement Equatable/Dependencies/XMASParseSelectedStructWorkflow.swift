import SwiftXPC
import Foundation
import SourceKittenFramework

@objc public class XMASParseSelectedStructWorkflow : NSObject {
    var swiftParser : XMASSwiftParser
    private(set) public var selectedStructOracle: XMASSelectedStructOracle

    public init(structOracle : XMASSelectedStructOracle) {
        swiftParser = XMASSwiftParser.init()
        selectedStructOracle = structOracle
    }

    @objc dynamic public func selectedStructInFile(filePath : String!) throws -> StructDeclaration {
        guard let sourceFile = File.init(path: filePath) as File! else {
            let userInfo = [NSLocalizedFailureReasonErrorKey: "could not read " + filePath]
            throw NSError.init(domain: errorDomain, code: 5, userInfo: userInfo)
        }

        let fileStructure = Structure.init(file: sourceFile)
        guard let substructure = fileStructure.dictionary["key.substructure"] as? XPCArray else {
            throw NSError.init(domain: errorDomain, code: 55, userInfo: nil)
        }

        for item in substructure {
            guard let dictionary = item as? XPCDictionary else {
                continue
            }

            guard let structDecl : StructDeclaration =
                try swiftParser.parseStructDeclaration(dictionary, filePath: filePath)
                else { continue }

            if selectedStructOracle.isStructSelected(structDecl) {
                return structDecl
            }
        }

        let userInfo = [NSLocalizedFailureReasonErrorKey: "No struct was selected"]
        throw NSError.init(domain: errorDomain, code: 1, userInfo: userInfo)
    }
}

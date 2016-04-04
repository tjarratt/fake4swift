import SwiftXPC
import Foundation
import SourceKittenFramework

let errorDomain : String = "parse-swift-protocol-domain"

@objc public class XMASParseSelectedProtocolWorkFlow : NSObject {
    var swiftParser : XMASSwiftParser
    private(set) public var selectedProtocolOracle : XMASSelectedProtocolOracle

    public init(protocolOracle : XMASSelectedProtocolOracle) {
        swiftParser = XMASSwiftParser.init()
        selectedProtocolOracle = protocolOracle
    }

    @objc public func selectedProtocolInFile(filePath : String!) throws -> ProtocolDeclaration {
        guard let sourceFile = File.init(path: filePath) as File! else {
            throw NSError.init(domain: errorDomain, code: 5, userInfo: [NSLocalizedFailureReasonErrorKey: "could not read " + filePath])
        }

        let fileStructure = Structure.init(file: sourceFile)
        guard let substructure = fileStructure.dictionary["key.substructure"] as? [SourceKitRepresentable] else {
            throw NSError.init(domain: errorDomain, code: 55, userInfo: nil)
        }

        for item in substructure {
            guard let protocolDict = item as? [String: SourceKitRepresentable] else {
                continue
            }

            guard let protocolDecl : ProtocolDeclaration = try swiftParser.parseProtocolDeclaration(protocolDict, filePath: filePath) else {
                continue
            }

            if selectedProtocolOracle.isProtocolSelected(protocolDecl) {
                return protocolDecl
            }
        }

        let userInfo = [NSLocalizedFailureReasonErrorKey: "No protocol was selected"]
        throw NSError.init(domain: errorDomain, code: 1, userInfo: userInfo)
    }
}

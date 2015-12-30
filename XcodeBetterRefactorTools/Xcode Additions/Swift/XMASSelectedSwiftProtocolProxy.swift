import AppKit
import SwiftXPC
import SourceKittenFramework

let protocolDeclKind   : String = "source.lang.swift.decl.protocol"
let instanceVarKind    : String = "source.lang.swift.decl.var.instance"
let staticVarKind      : String = "source.lang.swift.decl.var.static"
let instanceMethodKind : String = "source.lang.swift.decl.function.method.instance"
let staticMethodKind   : String = "source.lang.swift.decl.function.method.static"
let mutableMethodKind  : String = "source.decl.attribute.mutating"

let errorDomain : String = "parse-swift-protocol-domain"

@objc class XMASSelectedSwiftProtocolProxy: NSObject, XMASSelectedTextProxy {
    var swiftParser : XMASSwiftParser
    var selectedProtocolOracle : XMASSelectedProtocolOracle

    init(protocolOracle : XMASSelectedProtocolOracle) {
        swiftParser = XMASSwiftParser.init()
        selectedProtocolOracle = protocolOracle
    }

    @objc func selectedProtocolInFile(filePath : String!) throws -> ProtocolDeclaration {
        guard let sourceFile = File.init(path: filePath) as File! else {
            throw NSError.init(domain: errorDomain, code: 5, userInfo: [NSLocalizedFailureReasonErrorKey: "could not read " + filePath])
        }

        let fileStructure = Structure.init(file: sourceFile)
        guard let substructure = fileStructure.dictionary["key.substructure"] as? XPCArray else {
            throw NSError.init(domain: errorDomain, code: 55, userInfo: nil)
        }

        for item in substructure {
            guard let protocolDict = item as? XPCDictionary else {
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

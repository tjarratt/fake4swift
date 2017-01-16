import Foundation

@objc public protocol XMASSelectedProtocolOracle {
    @objc func isProtocolSelected(_ protocolDecl : ProtocolDeclaration) -> Bool
}

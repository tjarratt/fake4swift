import Foundation

@objc public protocol XMASSelectedStructOracle {
    @objc func isStructSelected(_ structDecl : StructDeclaration) -> Bool
}

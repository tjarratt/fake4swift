import Foundation

@objc public protocol XMASSelectedStructOracle {
    @objc func isStructSelected(structDecl : StructDeclaration) -> Bool
}
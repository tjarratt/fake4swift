import Mustache
import Foundation

@objc open class XMASEquatableTemplateStamper : NSObject {
    fileprivate(set) open var bundle : Bundle

    @objc public init(bundle: Bundle) {
        self.bundle = bundle
    }

    @objc open func equatableImplementationForStruct(_ structDecl: StructDeclaration) throws -> String {

        let templateName = "SwiftEquatableStruct"
        let path : String! = self.bundle.path(forResource: templateName, ofType: "mustache")

        guard path != nil else {
            let userInfo = [NSLocalizedFailureReasonErrorKey: "Fatal : missing template: " + templateName]
            throw NSError.init(
                domain: "swift-implement-equatable-domain",
                code: 2,
                userInfo: userInfo
            )
        }

        let template = try Template(path: path)
        let result : String = try template.render(boxDataForStruct(structDecl))

        return result.components(separatedBy: "\n").filter({
            !$0.hasPrefix("*")
            }).joined(separator: "\n")
    }

    // Mark - Private 

    fileprivate func boxDataForStruct(_ structDecl: StructDeclaration) -> MustacheBox {
        return Box([
            "name": structDecl.name,
            "field_equality_comparisons": equalityComparisons(structDecl.fieldNames)
            ])
    }

    fileprivate func equalityComparisons(_ fields: [String]) -> String {
        return fields.map({ "a." + $0 + " == b." + $0 }).joined(separator: " &&\n           ")
    }
}

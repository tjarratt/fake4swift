import Mustache
import Foundation

@objc public class XMASEquatableTemplateStamper : NSObject {
    private(set) public var bundle : NSBundle

    @objc public init(bundle: NSBundle) {
        self.bundle = bundle
    }

    @objc public func equatableImplementationForStruct(structDecl: StructDeclaration) throws -> String {

        let templateName = "SwiftEquatableStruct"
        let path : String! = self.bundle.pathForResource(templateName, ofType: "mustache")

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

        return result.componentsSeparatedByString("\n").filter({
            !$0.hasPrefix("*")
            }).joinWithSeparator("\n")
    }

    // Mark - Private 

    private func boxDataForStruct(structDecl: StructDeclaration) -> MustacheBox {
        return Box([
            "name": structDecl.name,
            "field_equality_comparisons": equalityComparisons(structDecl.fieldNames)
            ])
    }

    private func equalityComparisons(fields: [String]) -> String {
        return fields.map({ "a." + $0 + " == b." + $0 }).joinWithSeparator(" &&\n           ")
    }
}
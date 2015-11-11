import Foundation
import Mustache

class XMASSwiftProtocolFaker: NSObject {

    var bundle : NSBundle
    init(bundle: NSBundle) {
        self.bundle = bundle
    }

    func fakeForProtocol(protocolDecl: ProtocolDeclaration) throws -> String {
        let templateName = protocolDecl.mutatingMethods.isEmpty ? "SwiftCounterfeitClass" : "SwiftCounterfeitStruct"
        let path : String! = self.bundle.pathForResource(templateName, ofType: "mustache")

        guard path != nil else {
            throw(NSError.init(
                domain: "swift-counterfeiter-domain",
                code: 1,
                userInfo: [NSLocalizedFailureReasonErrorKey: "missing template: " + templateName])
            )
        }

        let template = try Template(path: path)
        let result : String = try template.render(boxDataForProtocol(protocolDecl))

        return result.componentsSeparatedByString("\n").filter( {
            !$0.hasPrefix("*")
        }).joinWithSeparator("\n").stringByReplacingOccurrencesOfString("}\n\n\n", withString: "}\n")
    }

// Mark - Private methods

    private func boxDataForProtocol(protocolDecl: ProtocolDeclaration) -> MustacheBox {
        return Box([
            "protocol_name": protocolDecl.name,
            "getters": protocolDecl.getters.map(mapAccessorToDict),
            "setters": protocolDecl.setters.map(mapAccessorToDict),
            "instance_methods": protocolDecl.instanceMethods.map(mapMethodsToDict),
            "static_methods": protocolDecl.staticMethods.map(mapMethodsToDict),
            "mutating_methods": protocolDecl.mutatingMethods.map(mapMethodsToDict),
            ])
    }

    private func upcase(str : String) -> String {
        return str.stringByReplacingCharactersInRange(str.startIndex...str.startIndex,
            withString: String(str[str.startIndex]).capitalizedString)
    }

    private func namedArgumentsFor(methodDecl: MethodDeclaration) -> String {
        return methodDecl.arguments.map { $0.name + ": " + $0.type }.joinWithSeparator(", ")
    }

    private func argumentNamesFor(methodDecl: MethodDeclaration) -> String {
        return methodDecl.arguments.map { $0.name }.joinWithSeparator(", ")
    }
    private func argumentTypesFor(methodDecl: MethodDeclaration) -> String {
        return methodDecl.arguments.map { $0.type }.joinWithSeparator(", ")
    }

    private func returnTypesFor(methodDecl: MethodDeclaration) -> String {
        return methodDecl.returnValueTypes.joinWithSeparator(", ")
    }

    private func optionalReturnsFor(methodDecl: MethodDeclaration) -> String {
        return methodDecl.hasReturnValues() ? "-> (" + returnTypesFor(methodDecl) + ") " : ""
    }

    private func mapAccessorToDict(accessor: Accessor) -> [String: AnyObject] {
        return [
            "name": accessor.name,
            "type": accessor.returnType,
            "capitalized_name": upcase(accessor.name),
        ]
    }

    private func mapMethodsToDict(method: MethodDeclaration) -> [String: AnyObject] {
        return [
            "name":                         method.name,
            "has_arguments":                method.hasArguments(),
            "named_arguments":              namedArgumentsFor(method),
            "comma_delimited_arg_names":    argumentNamesFor(method),
            "comma_delimited_arg_types":    argumentTypesFor(method),

            "has_return_values":            method.hasReturnValues(),
            "comma_delimited_return_types": returnTypesFor(method),
            "optional_return_expression":   optionalReturnsFor(method),
        ]
    }
}

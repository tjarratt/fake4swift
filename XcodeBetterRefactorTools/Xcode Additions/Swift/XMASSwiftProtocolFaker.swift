import Foundation
import Mustache

class XMASSwiftProtocolFaker: NSObject {

    func fakeForProtocol(protocolDecl: ProtocolDeclaration) -> String {
        if protocolDecl.mutatingMethods.isEmpty {
            return self.classImplementingProtocol(protocolDecl).stringByReplacingOccurrencesOfString("}\n\n\n", withString: "}\n")
        } else {
            return self.structImplementingProtocol(protocolDecl).stringByReplacingOccurrencesOfString("}\n\n\n", withString: "}\n")
        }
    }

    // private
    func structImplementingProtocol(protocolDecl: ProtocolDeclaration) -> String {
        let template = try! Template(named: "SwiftCounterfeitStruct")

        let boxedData = Box([
            "protocol_name": protocolDecl.name,
            "getters": protocolDecl.getters.map(mapAccessorToDict),
            "setters": protocolDecl.setters.map(mapAccessorToDict),
            "instance_methods": protocolDecl.instanceMethods.map(mapMethodsToDict),
            "static_methods": protocolDecl.staticMethods.map(mapMethodsToDict),
            "mutating_methods": protocolDecl.mutatingMethods.map(mapMethodsToDict),
            ])

        let result : String = try! template.render(boxedData)
        return result.componentsSeparatedByString("\n").filter( {
            !$0.hasPrefix("*")
        }).joinWithSeparator("\n")
    }

    func classImplementingProtocol(protocolDecl: ProtocolDeclaration) -> String {
        let template = try! Template(named: "SwiftCounterfeitClass")

        let boxedData = Box([
            "protocol_name": protocolDecl.name,
            "getters": protocolDecl.getters.map(mapAccessorToDict),
            "setters": protocolDecl.setters.map(mapAccessorToDict),
            "instance_methods": protocolDecl.instanceMethods.map(mapMethodsToDict),
            "static_methods": protocolDecl.staticMethods.map(mapMethodsToDict),
        ])

        let result : String = try! template.render(boxedData)
        return result.componentsSeparatedByString("\n").filter( {
            !$0.hasPrefix("*")
        }).joinWithSeparator("\n")
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

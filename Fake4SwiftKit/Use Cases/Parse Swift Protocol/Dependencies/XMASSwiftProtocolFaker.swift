import Mustache
import Foundation

@objc public protocol XMASSwiftProtocolFaking {
    @objc func fakeForProtocol(_ protocolDecl: ProtocolDeclaration) throws -> String
}

@objc open class XMASSwiftProtocolFaker: NSObject, XMASSwiftProtocolFaking {

    fileprivate(set) open var bundle : Bundle
    @objc public init(bundle: Bundle) {
        self.bundle = bundle
    }

    @objc open func fakeForProtocol(_ protocolDecl: ProtocolDeclaration) throws -> String {
        let templateName = protocolDecl.mutatingMethods.isEmpty ? "SwiftCounterfeitClass" : "SwiftCounterfeitStruct"
        let path : String! = self.bundle.path(forResource: templateName, ofType: "mustache")

        guard path != nil else {
            throw(NSError.init(
                domain: "swift-counterfeiter-domain",
                code: 1,
                userInfo: [NSLocalizedFailureReasonErrorKey: "missing template: " + templateName])
            )
        }

        let template = try Template(path: path)
        let result : String = try template.render(boxDataForProtocol(protocolDecl))

        return result.components(separatedBy: "\n").filter( {
            !$0.hasPrefix("*")
        }).joined(separator: "\n").replacingOccurrences(of: "}\n\n\n", with: "}\n").appending("\n")
    }

// Mark - Private methods

    fileprivate func boxDataForProtocol(_ protocolDecl: ProtocolDeclaration) -> MustacheBox {
        return Box([
            "protocol_name": protocolDecl.name,
            "getters": protocolDecl.getters.map(mapAccessorToDict),
            "setters": protocolDecl.setters.map(mapAccessorToDict),
            "instance_methods": protocolDecl.instanceMethods.map(mapMethodsToDict),
            "static_methods": protocolDecl.staticMethods.map(mapMethodsToDict),
            "mutating_methods": protocolDecl.mutatingMethods.map(mapMethodsToDict),
            "imports": protocolDecl.imports.map(mapImportsToDict)
            ])
    }

    fileprivate func upcase(_ str : String) -> String {
        let first = String(str.characters.prefix(1)).capitalized
        let other = String(str.characters.dropFirst())
        return first + other
    }

    fileprivate func namedArgumentsFor(_ methodDecl: MethodDeclaration) -> String {
        return methodDecl.arguments.map { $0.name + ": " + $0.type }.joined(separator: ", ")
    }

    fileprivate func namedArgumentsWithLabels(_ methodDecl: MethodDeclaration) -> String {
        return methodDecl.arguments.map {
            if $0.externalName != $0.name {
                return $0.externalName + " " + $0.name + ": " + $0.type
            } else {
                return $0.name + ": " + $0.type
            }
        }.joined(separator: ", ")
    }

    fileprivate func argumentNamesFor(_ methodDecl: MethodDeclaration) -> String {
        return methodDecl.arguments.map { $0.name }.joined(separator: ", ")
    }
    fileprivate func argumentTypesFor(_ methodDecl: MethodDeclaration) -> String {
        return methodDecl.arguments.map { $0.type }.joined(separator: ", ")
    }

    fileprivate func returnTypesFor(_ methodDecl: MethodDeclaration) -> String {
        return methodDecl.returnValueTypes.joined(separator: ", ")
    }

    fileprivate func optionalReturnsFor(_ methodDecl: MethodDeclaration) -> String {
        return methodDecl.hasReturnValues() ? "-> (" + returnTypesFor(methodDecl) + ") " : ""
    }

    fileprivate func mapAccessorToDict(_ accessor: Accessor) -> [String: AnyObject] {
        return [
            "name": accessor.name as AnyObject,
            "type": accessor.returnType as AnyObject,
            "optional": accessor.optional as AnyObject,
            "capitalized_name": upcase(accessor.name) as AnyObject,
        ]
    }

    fileprivate func mapImportsToDict(_ importName: String) -> [String: AnyObject] {
        return [ "name": importName as AnyObject ]
    }

    fileprivate func mapMethodsToDict(_ method: MethodDeclaration) -> [String: AnyObject] {
        return [
            "name":                         method.name as AnyObject,
            "has_arguments":                method.hasArguments() as AnyObject,
            "named_arguments":              namedArgumentsFor(method) as AnyObject,
            "named_arguments_with_labels":  namedArgumentsWithLabels(method) as AnyObject,
            "comma_delimited_arg_names":    argumentNamesFor(method) as AnyObject,
            "comma_delimited_arg_types":    argumentTypesFor(method) as AnyObject,
            "throws":                       (method.throwsError ? " throws " : " ") as AnyObject,
            "has_return_values":            method.hasReturnValues() as AnyObject,
            "comma_delimited_return_types": returnTypesFor(method) as AnyObject,
            "optional_return_expression":   optionalReturnsFor(method) as AnyObject,
            "pre_stub_invocation":          (method.throwsError ? "try " : "") as AnyObject,
        ]
    }
}

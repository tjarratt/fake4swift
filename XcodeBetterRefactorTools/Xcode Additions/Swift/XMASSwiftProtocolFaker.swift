import Foundation

class XMASSwiftProtocolFaker: NSObject {

    func fakeForProtocol(protocolDecl: ProtocolDeclaration) -> String {
        var lines : Array<Array<String>> = []

        lines.append(["import", "Foundation"])
        lines.append([])
        lines.append(classDeclarationForFakeImplementingProtocol(protocolDecl))
        lines.appendContentsOf(initializerForFakeImplementingProtocol(protocolDecl))
        lines.appendContentsOf(mutableVarsForFakeImplementingProtocol(protocolDecl))
        lines.appendContentsOf(customGetterSettersForFakeImplementingProtocol(protocolDecl))
        lines.appendContentsOf(assertionHelpersForAccessorsForFakeImplementingProtocol(protocolDecl))
        lines.appendContentsOf(implsForInstanceMethodsForFakeImplementingProtocol(protocolDecl))
        lines.append(["}"])
        lines.append([])

        return lines.map({ (tokens : Array<String>) -> String in
            return tokens.joinWithSeparator(" ")
        }).joinWithSeparator("\n")
    }

    func classDeclarationForFakeImplementingProtocol(protocolDecl: ProtocolDeclaration) -> Array<String> {
        return ["class",
                "Fake" + protocolDecl.name,
                ":",
                protocolDecl.name,
                "{",
            ]
    }

    func initializerForFakeImplementingProtocol(protocolDecl: ProtocolDeclaration) -> Array<Array<String>> {
        var lines : Array<Array<String>> = [["    init() {"]]

        for accessor in protocolDecl.getters {
            lines.append(["        self.set_" + accessor.name + "Args", "=", "[]"])
        }
        for accessor in protocolDecl.setters {
            lines.append(["        self.set_" + accessor.name + "Args", "=", "[]"])
        }
        for method in protocolDecl.instanceMethods {
            if method.hasArguments() {
                lines.append(["        self." + method.name + "Args = []"])
            }
            lines.append(["        self." + method.name + "CallCount = 0"])
        }

        lines.append(["    }"])
        lines.append([])

        return lines
    }

    func mutableVarsForFakeImplementingProtocol(protocolDecl: ProtocolDeclaration) -> Array<Array<String>> {
        var lines : Array<Array<String>> = []

        for accessor in protocolDecl.getters {
            lines.append(["    private var", "_" + accessor.name, ":", accessor.returnType + "?"])
            lines.append(["    private var", "set_" + accessor.name + "Args", ":", "Array<" + accessor.returnType + ">"])
            lines.append([])
        }
        for accessor in protocolDecl.setters {
            lines.append(["    private var", "_" + accessor.name, ":", accessor.returnType + "?"])
            lines.append(["    private var", "set_" + accessor.name + "Args", ":", "Array<" + accessor.returnType + ">"])
            lines.append([])
        }

        return lines
    }

    func customGetterSettersForFakeImplementingProtocol(protocolDecl: ProtocolDeclaration) -> Array<Array<String>> {
        var lines : Array<Array<String>> = []

        for accessor in protocolDecl.getters {
            lines.append(["    var", accessor.name, ":", accessor.returnType, "{"])
            lines.append(["        get", "{"])
            lines.append(["            return", "_" + accessor.name + "!"])
            lines.append(["        }"])

            lines.append([])

            lines.append(["        set", "{"])
            lines.append(["            _" + accessor.name, "=", "newValue"])
            lines.append(["            set_" + accessor.name + "Args.append(newValue)"])
            lines.append(["        }"])
            lines.append(["    }"])
            lines.append([])
        }
        for accessor in protocolDecl.setters {
            lines.append(["    var", accessor.name, ":", accessor.returnType, "{"])
            lines.append(["        get", "{"])
            lines.append(["            return", "_" + accessor.name + "!"])
            lines.append(["        }"])

            lines.append([])

            lines.append(["        set", "{"])
            lines.append(["            _" + accessor.name, "=", "newValue"])
            lines.append(["            set_" + accessor.name + "Args.append(newValue)"])
            lines.append(["        }"])
            lines.append(["    }"])
            lines.append([])
        }

        return lines
    }

    func upcase(str : String) -> String {
        return str.stringByReplacingCharactersInRange(str.startIndex...str.startIndex,
                                            withString: String(str[str.startIndex]).capitalizedString)
    }

    func assertionHelpersForAccessorsForFakeImplementingProtocol(protocolDecl: ProtocolDeclaration) -> Array<Array<String>> {
        var lines : Array<Array<String>> = []

        for accessor in protocolDecl.getters {
            lines.append(["    func set" + upcase(accessor.name) + "CallCount()", "->", "Int", "{"])
            lines.append(["        return", "set_" + accessor.name + "Args.count"])
            lines.append(["    }"])

            lines.append([])

            lines.append(["    func set" + upcase(accessor.name) + "ArgsForCall(index : Int)", "throws", "->", accessor.returnType, "{"])
            lines.append(["        if index < 0 || index >=", "set_" + accessor.name + "Args.count", "{"])
            lines.append(["            throw NSError.init(domain: \"swift-generate-fake-domain\", code: 1, userInfo: nil)"])
            lines.append(["        }"])
            lines.append(["        return", "set_" + accessor.name + "Args[index]"])
            lines.append(["    }"])
            lines.append([])
        }

        for accessor in protocolDecl.setters {
            lines.append(["    func set" + upcase(accessor.name) + "CallCount()", "->", "Int", "{"])
            lines.append(["        return", "set_" + accessor.name + "Args.count"])
            lines.append(["    }"])

            lines.append([])

            lines.append(["    func set" + upcase(accessor.name) + "ArgsForCall(index : Int)", "throws", "->", accessor.returnType, "{"])
            lines.append(["        if index < 0 || index >=", "set_" + accessor.name + "Args.count", "{"])
            lines.append(["            throw NSError.init(domain: \"swift-generate-fake-domain\", code: 1, userInfo: nil)"])
            lines.append(["        }"])
            lines.append(["        return", "set_" + accessor.name + "Args[index]"])
            lines.append(["    }"])
            lines.append([])
        }

        return lines
    }

    func implsForInstanceMethodsForFakeImplementingProtocol(protocolDecl: ProtocolDeclaration) -> Array<Array<String>> {
        var lines : Array<Array<String>> = []

        for method in protocolDecl.instanceMethods {
            lines.append(["    var " + method.name + "CallCount : Int"])

            let returnTypes : String = concatReturnTypes(method.returnValueTypes)
            let argTypes : String = concatArgTypes(method.arguments)
            let namedArguments : String = concatNamedArguments(method.arguments)

            if method.hasReturnValues() {
                lines.append(["    var", method.name + "Stub : (" + argTypes, "->", returnTypes + ")?"])
            }

            if method.hasArguments() {
                lines.append(["    private var", method.name + "Args : Array<" + argTypes + ">"])
            }

            if method.hasReturnValues() {
                lines.append(["    func", method.name + "Returns(stubbedValues:", concatReturnTypes(method.returnValueTypes) + ") {"])
                lines.append(["        self." + method.name + "Stub = {" + namedArguments, "->", returnTypes, "in"])
                lines.append(["            return stubbedValues"])
                lines.append(["        }"])
                lines.append(["    }"])
            }

            if method.hasArguments() {
                lines.append(["    func", method.name + "ArgsForCall(callIndex: Int) ->", argTypes, "{"])
                lines.append(["        return self." + method.name + "Args[callIndex]"])
                lines.append(["    }"])
            }

            let returnArrow : String = method.hasReturnValues() ? " -> " + returnTypes : ""
            let argumentNames : String = method.arguments.map { $0.name }.joinWithSeparator(", ")

            lines.append(["    func", method.name + namedArguments + returnArrow + " {"])
            lines.append(["        self." + method.name + "CallCount++"])
            if method.hasArguments() {
                lines.append(["        self." + method.name + "Args.append((" + argumentNames + "))"])
            }
            if method.hasReturnValues() {
                lines.append(["        return self." + method.name + "Stub!(" + argumentNames + ")"])
            }
            lines.append(["    }"])
            lines.append([])
        }

        lines.removeLast()

        return lines
    }

    func concatReturnTypes(returnTypes : Array<ReturnType>) -> String {
        return "(" + returnTypes.joinWithSeparator(", ") + ")"
    }

    func concatArgTypes(args : Array<MethodParameter>) -> String {
        return "(" + args.map { $0.type }.joinWithSeparator(", ") + ")"
    }

    func concatNamedArguments(args : Array<MethodParameter>) -> String {
        return "(" + args.map { $0.name + ": " + $0.type }.joinWithSeparator(", ") + ")"
    }
}

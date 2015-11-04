import Foundation

class XMASSwiftProtocolFaker: NSObject {

    func fakeForProtocol(protocolDecl: ProtocolDeclaration) -> String {
        var lines : Array<Array<String>> = []

        lines.append(classDeclarationForFakeImplementingProtocol(protocolDecl))
        lines.appendContentsOf(initializerForFakeImplementingProtocol(protocolDecl))
        lines.appendContentsOf(mutableVarsForFakeImplementingProtocol(protocolDecl))
        lines.appendContentsOf(customGetterSettersForFakeImplementingProtocol(protocolDecl))
        lines.appendContentsOf(assertionHelpersForAccessorsForFakeImplementingProtocol(protocolDecl))
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
            lines.append(["        self._set_" + accessor.name + "Args", "=", "[]"])
        }
        for accessor in protocolDecl.setters {
            lines.append(["        self._set_" + accessor.name + "Args", "=", "[]"])
        }

        lines.append(["    }"])
        lines.append([])

        return lines
    }

    func mutableVarsForFakeImplementingProtocol(protocolDecl: ProtocolDeclaration) -> Array<Array<String>> {
        var lines : Array<Array<String>> = []

        for accessor in protocolDecl.getters {
            lines.append(["    var", "_" + accessor.name, ":", accessor.returnType + "?"])
            lines.append(["    var", "_set_" + accessor.name + "Args", ":", "Array<" + accessor.returnType + ">"])
            lines.append([])
        }
        for accessor in protocolDecl.setters {
            lines.append(["    var", "_" + accessor.name, ":", accessor.returnType + "?"])
            lines.append(["    var", "_set_" + accessor.name + "Args", ":", "Array<" + accessor.returnType + ">"])
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
            lines.append(["            _set_" + accessor.name + "Args.append(newValue)"])
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
            lines.append(["            _set_" + accessor.name + "Args.append(newValue)"])
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
            lines.append(["        return", "_set_" + accessor.name + "Args.count"])
            lines.append(["    }"])

            lines.append([])

            lines.append(["    func set" + upcase(accessor.name) + "ArgsForCall(index : Int)", "throws", "->", accessor.returnType, "{"])
            lines.append(["        return", "_set_" + accessor.name + "Args[index]"])
            lines.append(["    }"])
            lines.append([])
        }

        for accessor in protocolDecl.setters {
            lines.append(["    func set" + upcase(accessor.name) + "CallCount()", "->", "Int", "{"])
            lines.append(["        return", "_set_" + accessor.name + "Args.count"])
            lines.append(["    }"])

            lines.append([])

            lines.append(["    func set" + upcase(accessor.name) + "ArgsForCall(index : Int)", "throws", "->", accessor.returnType, "{"])
            lines.append(["        return", "_set_" + accessor.name + "Args[index]"])
            lines.append(["    }"])
            lines.append([])
        }

        return lines
    }
}

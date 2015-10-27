import Foundation

struct MethodDeclaration {
    var name : MethodName
    var arguments : Array<(String, String)>
    var returnValueTypes : Array<String>
    var optional : Bool
}

typealias MethodName = String

// random thought :: we should PROBABLY `import` everything from the file, right?
// does source kitten give us that? (PLEASE SAY YES)
@objc class ProtocolDeclaration : NSObject {
    var name : String

    init(name: String,
        classOnly: Bool,
        includedProtocols: Array<ProtocolDeclaration>,
        normalFuncs: Array<MethodDeclaration>,
        staticFuncs: Array<MethodDeclaration>,
        mutatingFuncs: Array<MethodDeclaration>,
        initializers: Array<MethodDeclaration>,
        getters: Array<(MethodName, String)>,
        setters: Array<(MethodName, String)>,
        subscriptGetters: Array<(MethodName, String)>,
        subscriptSetters: Array<(MethodName, String)>
        ) {
            self.name = name
            self.includedProtocols = includedProtocols
            self.implementableByClassOnly = classOnly
            self.normalFuncs = normalFuncs
            self.staticFuncs = staticFuncs
            self.mutatingFuncs = mutatingFuncs
            self.initializers = initializers
            self.getters = getters
            self.setters = setters
            self.subscriptGetters = subscriptGetters
            self.subscriptSetters = subscriptSetters
            return
    }

    var normalFuncs : Array<MethodDeclaration>
    var staticFuncs : Array<MethodDeclaration>
    var mutatingFuncs : Array<MethodDeclaration>

    var initializers : Array<MethodDeclaration>

    var getters : Array<(MethodName, String)>
    var setters : Array<(MethodName, String)>

    var subscriptGetters : Array<(MethodName, String)>
    var subscriptSetters : Array<(MethodName, String)>

    var includedProtocols : Array<ProtocolDeclaration>
    var implementableByClassOnly : Bool
}
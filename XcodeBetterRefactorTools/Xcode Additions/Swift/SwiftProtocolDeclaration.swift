import Foundation

@objc class MethodDeclaration : NSObject {
    var name : MethodName
    var arguments : Array<(String, String)>
    var returnValueTypes : Array<String>
    var optional : Bool

    init(name: String,
        arguments: Array<(String, String)>,
        returnValueTypes: Array<String>,
        optional: Bool) {
            self.name = name
            self.arguments = arguments
            self.returnValueTypes = returnValueTypes
            self.optional = optional
    }
}

@objc class Accessor : NSObject {
    var name : MethodName
    var returnType : ReturnType

    init(name: MethodName,
        returnType: ReturnType) {
            self.name = name
            self.returnType = returnType
    }

    override func isEqual(object: AnyObject?) -> Bool {
        if let other = object as? Accessor? {
            return other?.name == self.name && other?.returnType == self.returnType
        }

        return false
    }
}

typealias MethodName = String
typealias ReturnType = String

// random thought :: we should PROBABLY `import` everything from the file, right?
// does source kitten give us that? (PLEASE SAY YES)
@objc class ProtocolDeclaration : NSObject {
    var name : String

    init(name: String,
        includedProtocols: Array<ProtocolDeclaration>,
        normalFuncs: Array<MethodDeclaration>,
        staticFuncs: Array<MethodDeclaration>,
        mutatingFuncs: Array<MethodDeclaration>,
        initializers: Array<MethodDeclaration>,
        getters: Array<Accessor>,
        setters: Array<Accessor>,
        subscriptGetters: Array<Accessor>,
        subscriptSetters: Array<Accessor>
        ) {
            self.name = name
            self.includedProtocols = includedProtocols
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

    var getters : Array<Accessor>
    var setters : Array<Accessor>

    var subscriptGetters : Array<Accessor>
    var subscriptSetters : Array<Accessor>

    var includedProtocols : Array<ProtocolDeclaration>
}
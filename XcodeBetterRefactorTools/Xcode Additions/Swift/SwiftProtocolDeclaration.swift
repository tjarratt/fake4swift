import Foundation

@objc class MethodParameter : NSObject {
    var name : MethodName
    var type : ReturnType

    init(name: MethodName, type: ReturnType) {
        self.name = name
        self.type = type
    }
}

@objc class MethodDeclaration : NSObject {
    var name : MethodName
    var throwsError : Bool
    var arguments : Array<MethodParameter>
    var returnValueTypes : Array<ReturnType>

    init(name: String,
        throwsError: Bool,
        arguments: Array<MethodParameter>,
        returnValueTypes: Array<ReturnType>) {
            self.name = name
            self.throwsError = throwsError
            self.arguments = arguments
            self.returnValueTypes = returnValueTypes
    }

    func hasArguments() -> Bool {
        return arguments.count > 0
    }

    func hasReturnValues() -> Bool {
        return returnValueTypes.count > 0
    }

    override func isEqual(object: AnyObject?) -> Bool {
        if let other = object as? MethodDeclaration {
            return self.name == other.name &&
                self.arguments == other.arguments &&
                self.returnValueTypes == other.returnValueTypes &&
                self.throwsError == other.throwsError
        }

        return false
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
}

typealias MethodName = String
typealias ReturnType = String

// random thought :: we should PROBABLY `import` everything from the file, right?
// does source kitten give us that? (PLEASE SAY YES)
@objc class ProtocolDeclaration : NSObject {
    var name : String

    init(name: String,
        includedProtocols: Array<ProtocolDeclaration>,
        instanceMethods: Array<MethodDeclaration>,
        staticMethods: Array<MethodDeclaration>,
        mutatingMethods: Array<MethodDeclaration>,
        initializers: Array<MethodDeclaration>,
        getters: Array<Accessor>,
        setters: Array<Accessor>,
        staticGetters: Array<Accessor>,
        staticSetters: Array<Accessor>,
        subscriptGetters: Array<Accessor>,
        subscriptSetters: Array<Accessor>
        ) {
            self.name = name
            self.includedProtocols = includedProtocols
            self.instanceMethods = instanceMethods
            self.staticMethods = staticMethods
            self.mutatingMethods = mutatingMethods
            self.initializers = initializers
            self.getters = getters
            self.setters = setters
            self.staticGetters = staticGetters
            self.staticSetters = staticSetters
            self.subscriptGetters = subscriptGetters
            self.subscriptSetters = subscriptSetters
            return
    }

    var instanceMethods : Array<MethodDeclaration>
    var staticMethods : Array<MethodDeclaration>
    var mutatingMethods : Array<MethodDeclaration>

    var initializers : Array<MethodDeclaration>

    var getters : Array<Accessor>
    var setters : Array<Accessor>

    var staticGetters : Array<Accessor>
    var staticSetters : Array<Accessor>

    var subscriptGetters : Array<Accessor>
    var subscriptSetters : Array<Accessor>

    var includedProtocols : Array<ProtocolDeclaration>
}
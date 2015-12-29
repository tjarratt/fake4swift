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
    init(name: String,
        containingFile: String,
        rangeInFile: NSRange,
        usesTypealias: Bool,
        includedProtocols: Array<String>,
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
            self.containingFile = containingFile
            self.rangeInFile = rangeInFile
            self.usesTypealias = usesTypealias
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

    override func isEqual(object: AnyObject?) -> Bool {
        if let other = object as? ProtocolDeclaration {
            return self.name == other.name &&
                self.containingFile == other.containingFile &&
                NSEqualRanges(self.rangeInFile, other.rangeInFile) &&
                self.usesTypealias == other.usesTypealias &&
                self.includedProtocols == other.includedProtocols &&
                self.instanceMethods == other.instanceMethods &&
                self.staticMethods == other.staticMethods &&
                self.mutatingMethods == other.mutatingMethods &&
                self.initializers == other.initializers &&
                self.getters == other.getters &&
                self.setters == other.setters &&
                self.staticGetters == other.staticGetters &&
                self.staticSetters == other.staticSetters &&
                self.subscriptGetters == other.subscriptGetters &&
                self.subscriptSetters == other.subscriptSetters
        }

        return false
    }

    var name : String

    var containingFile : String
    var rangeInFile : NSRange

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

    var includedProtocols : Array<String>

    var usesTypealias : Bool
}
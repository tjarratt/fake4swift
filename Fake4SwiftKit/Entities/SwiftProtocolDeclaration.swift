import Foundation

@objc open class MethodParameter : NSObject {
    open var name : MethodName
    open var type : ReturnType

    init(name: MethodName, type: ReturnType) {
        self.name = name
        self.type = type
    }
}

@objc open class MethodDeclaration : NSObject {
    open var name : MethodName
    open var throwsError : Bool
    open var arguments : Array<MethodParameter>
    open var returnValueTypes : Array<ReturnType>

    init(name: String,
        throwsError: Bool,
        arguments: Array<MethodParameter>,
        returnValueTypes: Array<ReturnType>) {
            self.name = name
            self.throwsError = throwsError
            self.arguments = arguments
            self.returnValueTypes = returnValueTypes
    }

    open func hasArguments() -> Bool {
        return arguments.count > 0
    }

    open func hasReturnValues() -> Bool {
        return returnValueTypes.count > 0
    }

    override open func isEqual(_ object: Any?) -> Bool {
        if let other = object as? MethodDeclaration {
            return self.name == other.name &&
                self.arguments == other.arguments &&
                self.returnValueTypes == other.returnValueTypes &&
                self.throwsError == other.throwsError
        }

        return false
    }
}

@objc open class Accessor : NSObject {
    open var name : MethodName
    open var returnType : ReturnType
    open var optional : Optionality

    init(name: MethodName,
        returnType: ReturnType) {
            self.name = name
            self.returnType = returnType
            self.optional = returnType.hasSuffix("?")
    }
}

public typealias MethodName = String
public typealias ReturnType = String
public typealias Optionality = Bool

// random thought :: we should PROBABLY `import` everything from the file, right?
// does source kitten give us that? (PLEASE SAY YES)
@objc open class ProtocolDeclaration : NSObject {
    public init(name: String,
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
        subscriptSetters: Array<Accessor>,
        imports: Array<String>
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
            self.imports = imports
    }

    override open func isEqual(_ object: Any?) -> Bool {
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
                self.subscriptSetters == other.subscriptSetters &&
                self.imports == other.imports
        }

        return false
    }

    open var name : String

    open var containingFile : String
    open var rangeInFile : NSRange

    open var instanceMethods : Array<MethodDeclaration>
    open var staticMethods : Array<MethodDeclaration>
    open var mutatingMethods : Array<MethodDeclaration>

    open var initializers : Array<MethodDeclaration>

    open var getters : Array<Accessor>
    open var setters : Array<Accessor>

    open var staticGetters : Array<Accessor>
    open var staticSetters : Array<Accessor>

    open var subscriptGetters : Array<Accessor>
    open var subscriptSetters : Array<Accessor>

    open var includedProtocols : Array<String>

    open var usesTypealias : Bool

    open let imports : Array<String>
}

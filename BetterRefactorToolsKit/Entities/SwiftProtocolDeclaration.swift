import Foundation

@objc public class MethodParameter : NSObject {
    public var name : MethodName
    public var type : ReturnType

    init(name: MethodName, type: ReturnType) {
        self.name = name
        self.type = type
    }
}

@objc public class MethodDeclaration : NSObject {
    public var name : MethodName
    public var throwsError : Bool
    public var arguments : Array<MethodParameter>
    public var returnValueTypes : Array<ReturnType>

    init(name: String,
        throwsError: Bool,
        arguments: Array<MethodParameter>,
        returnValueTypes: Array<ReturnType>) {
            self.name = name
            self.throwsError = throwsError
            self.arguments = arguments
            self.returnValueTypes = returnValueTypes
    }

    public func hasArguments() -> Bool {
        return arguments.count > 0
    }

    public func hasReturnValues() -> Bool {
        return returnValueTypes.count > 0
    }

    override public func isEqual(object: AnyObject?) -> Bool {
        if let other = object as? MethodDeclaration {
            return self.name == other.name &&
                self.arguments == other.arguments &&
                self.returnValueTypes == other.returnValueTypes &&
                self.throwsError == other.throwsError
        }

        return false
    }
}

@objc public class Accessor : NSObject {
    public var name : MethodName
    public var returnType : ReturnType

    init(name: MethodName,
        returnType: ReturnType) {
            self.name = name
            self.returnType = returnType
    }
}

public typealias MethodName = String
public typealias ReturnType = String

// random thought :: we should PROBABLY `import` everything from the file, right?
// does source kitten give us that? (PLEASE SAY YES)
@objc public class ProtocolDeclaration : NSObject {
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

    override public func isEqual(object: AnyObject?) -> Bool {
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

    public var name : String

    public var containingFile : String
    public var rangeInFile : NSRange

    public var instanceMethods : Array<MethodDeclaration>
    public var staticMethods : Array<MethodDeclaration>
    public var mutatingMethods : Array<MethodDeclaration>

    public var initializers : Array<MethodDeclaration>

    public var getters : Array<Accessor>
    public var setters : Array<Accessor>

    public var staticGetters : Array<Accessor>
    public var staticSetters : Array<Accessor>

    public var subscriptGetters : Array<Accessor>
    public var subscriptSetters : Array<Accessor>

    public var includedProtocols : Array<String>

    public var usesTypealias : Bool
}
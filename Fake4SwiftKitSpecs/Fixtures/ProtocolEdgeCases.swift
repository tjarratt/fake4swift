import Foundation

protocol MySpecialProtocol {
    func voidMethod()
    func randomDouble() -> Double
    func randomDoubleWithSeed(seed: Int) -> Double
    func randomDoubleWithSeeds(seed: Int, secondSeed: Int) -> Double
    func returnsMultipleValues() -> (Double, Double)

    static func isStatic()
    init(this: Int, orThat: Int)

    subscript(subscriptAssignable : Int, areYouKidding : Float) -> Bool { get }
    subscript(noWay : Bool) -> Bool { get set }

    var numberOfWheels: Int { get }             //readonly
    var numberOfSomething: Int { get set }      //read-write

    static var classGetter : Int { get }
    static var classAccessor : Int { get set }

    // TODO : think about optionals
    // TODO : think about non-nils
    // e.g.: (does that affect params or return values?)

    // TODO : think about "out" params (e.g.: NSError **)
    
    // TODO : what about protocols with partial implementations (h/t to Alevine)
}

@objc protocol MyOptionalProtocol {
    optional func youMayOrMayNotImplementThis()
}

protocol IncludesOtherProtocol : MyOptionalProtocol, NSObjectProtocol { // this is right annoying
    func noWai()
}

protocol ImplementableByStructsOnly {
    mutating func mutates()
}

public protocol ImplementableByClassesOnly : class {

}

// basically you can declare what type of ItemType you want at compile type
// this is, in practice less powerful than C++ templates, but still pretty cool
protocol GenericProtocolWithTypeAlias {
    typealias ItemType
    mutating func append(item: ItemType)
    var count: Int { get }
    subscript(i: Int) -> ItemType { get }
}

protocol ThingsThatGoBoom {
    func thisVoidMethodThrows() throws
    func thisMethodThrowsToo() throws -> String
}
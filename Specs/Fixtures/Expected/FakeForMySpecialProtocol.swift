import Foundation

class FakeMySomewhatSpecialProtocol : MySomewhatSpecialProtocol {
    init() {
        self.set_myAttributeArgs = []
        self.set_myNameArgs = []
        self.doesNothingCallCount = 0
        self.doesStuffArgs = []
        self.doesStuffCallCount = 0
    }

    private var _myAttribute : Int?
    private var set_myAttributeArgs : Array<Int>

    private var _myName : String?
    private var set_myNameArgs : Array<String>

    var myAttribute : Int {
        get {
            return _myAttribute!
        }

        set {
            _myAttribute = newValue
            set_myAttributeArgs.append(newValue)
        }
    }

    var myName : String {
        get {
            return _myName!
        }

        set {
            _myName = newValue
            set_myNameArgs.append(newValue)
        }
    }

    func setMyAttributeCallCount() -> Int {
        return set_myAttributeArgs.count
    }

    func setMyAttributeArgsForCall(index : Int) throws -> Int {
        if index < 0 || index >= set_myAttributeArgs.count {
            throw NSError.init(domain: "swift-generate-fake-domain", code: 1, userInfo: nil)
        }
        return set_myAttributeArgs[index]
    }

    func setMyNameCallCount() -> Int {
        return set_myNameArgs.count
    }

    func setMyNameArgsForCall(index : Int) throws -> String {
        if index < 0 || index >= set_myNameArgs.count {
            throw NSError.init(domain: "swift-generate-fake-domain", code: 1, userInfo: nil)
        }
        return set_myNameArgs[index]
    }

    var doesNothingCallCount : Int
    func doesNothing() {
        self.doesNothingCallCount++
    }

    var doesStuffCallCount : Int
    var doesStuffStub : ((String, [String]) -> ([String], Int))?
    private var doesStuffArgs : Array<(String, [String])>
    func doesStuffReturns(stubbedValues: ([String], Int)) {
        self.doesStuffStub = {(stuff: String, otherStuff: [String]) -> ([String], Int) in
            return stubbedValues
        }
    }
    func doesStuffArgsForCall(callIndex: Int) -> (String, [String]) {
        return self.doesStuffArgs[callIndex]
    }
    func doesStuff(stuff: String, otherStuff: [String]) -> ([String], Int) {
        self.doesStuffCallCount++
        self.doesStuffArgs.append((stuff, otherStuff))
        return self.doesStuffStub!(stuff, otherStuff)
    }
}

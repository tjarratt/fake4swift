import Foundation

class FakeMySomewhatSpecialProtocol : MySomewhatSpecialProtocol {
    init() {
        self._set_myAttributeArgs = []
        self._set_myNameArgs = []
    }

    var _myAttribute : Int?
    var _set_myAttributeArgs : Array<Int>

    var _myName : String?
    var _set_myNameArgs : Array<String>

    var myAttribute : Int {
        get {
            return _myAttribute!
        }

        set {
            _myAttribute = newValue
            _set_myAttributeArgs.append(newValue)
        }
    }

    var myName : String {
        get {
            return _myName!
        }

        set {
            _myName = newValue
            _set_myNameArgs.append(newValue)
        }
    }

    func setMyAttributeCallCount() -> Int {
        return _set_myAttributeArgs.count
    }

    func setMyAttributeArgsForCall(index : Int) throws -> Int {
        if index < 0 || index >= _set_myAttributeArgs.count {
            throw NSError.init(domain: "swift-generate-fake-domain", code: 1, userInfo: nil)
        }
        return _set_myAttributeArgs[index]
    }

    func setMyNameCallCount() -> Int {
        return _set_myNameArgs.count
    }

    func setMyNameArgsForCall(index : Int) throws -> String {
        if index < 0 || index >= _set_myNameArgs.count {
            throw NSError.init(domain: "swift-generate-fake-domain", code: 1, userInfo: nil)
        }
        return _set_myNameArgs[index]
    }

}

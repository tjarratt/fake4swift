class FakeMySomewhatSpecialProtocol : MySomewhatSpecialProtocol {
    init() {
        self._myAttribute = 0
        self._set_myAttributeArgs = []
    }

    var _myAttribute : Int
    var _set_myAttributeArgs : Array<Int>

    var myAttribute : Int {
        get {
            return _myAttribute
        }

        set {
            _myAttribute = newValue
            _set_myAttributeArgs.append(newValue)
        }
    }

    func setMyAttributeCallCount() -> Int {
        return _set_myAttributeArgs.count
    }

    func setMyAttributeArgsForCall(index : Int) throws -> Int {
        return _set_myAttributeArgs[index]
    }
}


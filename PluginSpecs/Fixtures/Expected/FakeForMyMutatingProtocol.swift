import Foundation

// this file was generated by Xcode-Better-Refactor-Tools
// https://github.com/tjarratt/xcode-better-refactor-tools

struct FakeMyMutatingProtocol : MyMutatingProtocol, Equatable {
    private let hash: Int = Int(arc4random())

    init() {
    }

    private(set) var mutableMethodCallCount : Int = 0
    var mutableMethodStub : ((String, String) -> (String))?
    private var mutableMethodArgs : Array<(String, String)> = []
    mutating func mutableMethodReturns(stubbedValues: (String)) {
        self.mutableMethodStub = {(arg: String, arg2: String) -> (String) in
            return stubbedValues
        }
    }
    func mutableMethodArgsForCall(callIndex: Int) -> (String, String) {
        return self.mutableMethodArgs[callIndex]
    }
    mutating func mutableMethod(arg: String, arg2: String) -> (String) {
        self.mutableMethodCallCount++
        self.mutableMethodArgs.append((arg, arg2))
        return self.mutableMethodStub!(arg, arg2)
    }

    static func reset() {
    }
}

func == (a: FakeMyMutatingProtocol, b: FakeMyMutatingProtocol) -> Bool {
    return a.hash == b.hash
}
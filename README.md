`fake4swift` is a command line tool that generates type-safe test doubles for Swift.

This is handy if you want to easily generate mocks for protocols in Swift.

# Installation (ie: the "easy" way)
* `brew install tjarratt/fake4swift/fake4swift`

# Build from source (ie: "Installation the hard way")
* `git clone https://github.com/tjarratt/fake4swift.git`
* `git submodule update --init --recursive`
* `make prefix_install`

# Features
* [Generate test-doubles for Swift Protocols](#swift-fakes)

# swift-fakes
   Given a swift protocol...

   ```swift
   protocol MySomewhatSpecialProtocol {
    func doesStuff(stuff: String, otherStuff: [String]) -> ([String], Int)
}
   ```
   
   Run the fake4swift cli...
   
   ```bash
   fake4swift path/to/MySomewhatSpecialProtocol.swift MySomewhatSpecialProtocol
   ```
   
   It will generate a test double near it...
   ```bash
   path/to/fakes/FakeMySomewhatSpecialProtocol.swift
   ```

   You can use the generated fake in tests like so...

   ```swift
   describe("a generated fake for a contrived protocol") {
      var subject : FakeMySomewhatSpecialProtocol!

      beforeEach() {
          subject = FakeMySomewhatSpecialProtocol.init()
      }

      it("conforms to the MySomewhatSpecialProtocol protocol") {
          var test : MySomewhatSpecialProtocol
          test = subject
          expect(test).toNot(beNil())
      }

      it("allows you to stub the return value for methods that return values") {
         subject.doesStuffReturns((["test-yo"], 5))

         let tuple = subject.doesStuff("this", otherStuff: ["that"])
         expect(tuple.0).to(equal(["test-yo"]))
         expect(tuple.1).to(equal(5))
      }

      it("allows you to write assertions for the arguments passed into each invocation") {
         subject.doesStuffReturns(([], 0))
         subject.doesStuff("kool", otherStuff: ["keith"])

         var args = subject.doesStuffArgsForCall(0)
         expect(args.0).to(equal("kool"))
         expect(args.1).to(equal(["keith"]))

         subject.doesStuff("dr", otherStuff: ["octogon"])

         args = subject.doesStuffArgsForCall(1)
         expect(args.0).to(equal("dr"))
         expect(args.1).to(equal(["octogon"]))
      }
   }
   ```

# Known defects

* fake4swift   : Does not support initializers
* fake4swift   : Does not support protocols that include other protocols
* fake4swift   : Does not handle protocols that use `typealias` or `associatedtype`

# Feature backlog

[The backlog of features for this plugin is currently in Pivotal Tracker](https://www.pivotaltracker.com/n/projects/1394466).

# Contributing

Found a bug? Have a feature request? Interested in submitting a pull request? Please open an issue on Github (or just issue a pull request directly if the fix is pretty clear).

# Uninstall
`brew uninstall tjarratt/fake4swift/fake4swift`

# Would not have been possible without the hard work of
* Brian Croom -- fixed obnoxious `fake4swift` CLI warnings and added build infrastructure
* Rachel Brindle -- contributed expertise with Carthage, dynamic linking, homebrew

* Helen Tang -- created the 'fake mustache' icon (disguise by Helen Tseng from the Noun Project)
* Ludmil -- created the 'swift' icon (swallow by ludmil from the Noun Project)

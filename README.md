BetterRefactorTools is an Xcode plugin that adds handy utilities related to TDD and refactoring.

# Installation (the easy way)
* [download the most recent release](https://github.com/tjarratt/Xcode-Better-Refactor-Tools/releases)

# Build from source (ie: "Installation the hard way")
* `git clone https://github.com/tjarratt/Xcode-Better-Refactor-Tools.git`
* `cd Xcode-Better-Refactor-Tools`
* `git submodule update --init --recursive`
* `rake install`

# Features

* [Generate test-doubles for Swift Protocols](#swift-fakes)
* [Change an obj-c method's signature](#change-method-signature) (add, remove, edit selector components)

# swift-fakes
   <kbd>CTRL</kbd> + <kbd>g</kbd>
   
   (Edit > Generate Fake Protocol)

   Generates a file in your project with a test double that implements the Swift protocol under your cursor. Inspired by [counterfeiter](https://github.com/maxbrunsfeld/counterfeiter).
   
   Given a swift protocol...
   
   ```swift
   protocol MySomewhatSpecialProtocol {
    func doesStuff(stuff: String, otherStuff: [String]) -> ([String], Int)
}
   ```
   
   After you generate a fake and add the new file to your project, you can use the generated fake in tests like so...
   
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

# change-method-signature
   <kbd>CMD</kbd> + <kbd>F6</kbd>
   
   Refactor the method under the cursor. Add, remove and re-order selector components, change types and names.
   
   (Edit > Refactor Current Method)

# Known defects

* Generate Fake   : Does not support initializers
* Generate Fake   : Does not support protocols that include other protocols
* Generate Fake   : Does not handle protocols that use `typealias`
* Refactor Method : Only supports instance methods
* Refactor Method : ay get confused when an argument is a protocol type (e.g.: `id<AnyProtocol>`)
* Refactor Method : Cannot find call sites of methods in all `.mm` files. (especially Cedar specs)
* Refactor Method : Will rewrite **any** call site for selectors that match (e.g.: it will match any `-init` when rewriting call sites).
* Refactor Method : Will not rewrite any matching @selector()

# Feature backlog

[The backlog of features for this plugin is currently in Pivotal Tracker](https://www.pivotaltracker.com/n/projects/1394466).

# Contributing

Found a bug? Have a feature request? Interested in submitting a pull request? Please open an issue on Github (or just issue a pull request directly if the fix is pretty clear).

# Uninstalling the plugin
Plugin can be uninstalled by removing `XcodeBetterRefactorTools.xcplugin` from `~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins`

or

`rake uninstall`

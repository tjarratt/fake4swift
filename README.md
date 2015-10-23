BetterRefactorTools is an Xcode plugin that adds handy shortcuts for refactoring methods in Objective-C.

# Installation
* `git clone https://github.com/tjarratt/Xcode-Better-Refactor-Tools.git`
* `cd Xcode-Better-Refactor-Tools`
* `git submodule update --init --recursive`
* `rake install`

# Features

   <kbd>CTRL</kbd> + <kbd>g</kbd>

   Generate a class that implements the Swift protocol under your cursor.

   (Edit > Generate Fake Protocol)

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

BetterRefactorTools is an Xcode plugin that adds handy shortcuts for refactoring methods in Objective-C.

# Installation
* git clone https://github.com/tjarratt/Xcode-Better-Refactor-Tools.git
* cd Xcode-Better-Refactor-Tools
* rake install

# Features

* (note: this list may be incomplete)

   <kbd>CMD</kbd> + <kbd>F6</kbd>
   
   Refactor the method under the cursor. Add, remove and re-order selector components, change types and names.
   
   (Edit > Refactor Current Method)

# Known defects

* Only supports instance methods
* May get confused when an argument is a protocol type (e.g.: `id<AnyProtocol>`)
* Cannot find call sites of methods in all `.mm` files. (especially Cedar specs)
* Will rewrite **any** call site for selectors that match (e.g.: it will match any `-init` when rewriting call sites).
* Will not rewrite any matching @selector()

# Feature backlog

[The backlog of features for this plugin is currently in Pivotal Tracker](https://www.pivotaltracker.com/n/projects/1394466).

# Contributing

Found a bug? Have a feature request? Interested in submitting a pull request? Please open an issue on Github (or just issue a pull request directly if the fix is pretty clear).

# Uninstalling the plugin
Plugin can be uninstalled by removing `XcodeBetterRefactorTools.xcplugin` from `~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins`

or

`rake uninstall`

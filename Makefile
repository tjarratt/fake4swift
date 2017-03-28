TEMPDIR?=/tmp/fake4swift.dst
PREFIX?=/usr/local

FRAMEWORKS_FOLDER=/Library/Frameworks
BINARIES_FOLDER=/usr/local/bin

OUTPUT_FRAMEWORK=Fake4SwiftKit.framework

BUILT_BUNDLE=$(TEMPDIR)/bin/fake4swift.app
BUNDLED_FRAMEWORKS=$(BUILT_BUNDLE)/Contents/Frameworks/*.framework
FAKE4SWIFT_EXECUTABLE=$(BUILT_BUNDLE)/Contents/MacOS/fake4swift

XCODEFLAGS=-project 'Fake4Swift.xcodeproj' -scheme 'fake4swift' DSTROOT=$(TEMPDIR)

clean:
	rm -rf $(TEMPDIR)

ensure_carthage:
	brew install carthage

carthage_bootstrap:
	carthage bootstrap --platform mac --cache-builds

git_submodules:
	git submodule update --init --recursive

install:
	xcodebuild $(XCODEFLAGS) install
	mkdir -p "$(TEMPDIR)$(FRAMEWORKS_FOLDER)" "$(TEMPDIR)$(BINARIES_FOLDER)"
	mv -f $(BUNDLED_FRAMEWORKS) $(TEMPDIR)$(FRAMEWORKS_FOLDER)
	mv -f "$(FAKE4SWIFT_EXECUTABLE)" "$(TEMPDIR)$(BINARIES_FOLDER)/fake4swift"
	rm -rf "$(BUILT_BUNDLE)"
	mkdir -p "$(PREFIX)/Frameworks" "$(PREFIX)/bin"
	scripts/copy_frameworks.sh $(TEMPDIR)$(FRAMEWORKS_FOLDER)/ "$(PREFIX)/Frameworks/"
	cp -f "$(TEMPDIR)$(BINARIES_FOLDER)/fake4swift" "$(PREFIX)/bin/"

prefix_install: ensure_carthage clean carthage_bootstrap git_submodules install


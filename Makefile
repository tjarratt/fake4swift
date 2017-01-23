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

prefix_install: clean
	xcodebuild $(XCODEFLAGS) install
	mkdir -p "$(TEMPDIR)$(FRAMEWORKS_FOLDER)" "$(TEMPDIR)$(BINARIES_FOLDER)"
	mv -f $(BUNDLED_FRAMEWORKS) $(TEMPDIR)$(FRAMEWORKS_FOLDER)
	mv -f "$(FAKE4SWIFT_EXECUTABLE)" "$(TEMPDIR)$(BINARIES_FOLDER)/fake4swift"
	rm -rf "$(BUILT_BUNDLE)"
	mkdir -p "$(PREFIX)/Frameworks" "$(PREFIX)/bin"
	cp -Rf $(TEMPDIR)$(FRAMEWORKS_FOLDER)/*.framework "$(PREFIX)/Frameworks/"
	cp -f "$(TEMPDIR)$(BINARIES_FOLDER)/fake4swift" "$(PREFIX)/bin/"
	# install_name_tool -add_rpath "@executable_path/../Frameworks/$(OUTPUT_FRAMEWORK)/Versions/Current/Frameworks/"  "$(PREFIX)/bin/fake4swift"


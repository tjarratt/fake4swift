import AppKit

class XMASSelectedTextProxy: NSObject {

    func selectedProtocolInFile(fileName : String) -> String {
        let xcodeRepository = XMASXcodeRepository.init();
        let editor = xcodeRepository.currentEditor();

        let locations = editor.currentSelectedDocumentLocations();
        let lastLocation = locations.last;
        let selectedRange = lastLocation!.characterRange();

        var fileContents : NSString
        do {
            try fileContents = NSString.init(contentsOfFile: fileName, encoding: NSUTF8StringEncoding);
        } catch {
            return "";
        }

        // this should use SourceKitten to verify that this is indeed a protocol!!!

        return fileContents.substringWithRange(selectedRange);
    }

}

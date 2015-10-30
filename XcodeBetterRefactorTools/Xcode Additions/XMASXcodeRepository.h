#import <Cocoa/Cocoa.h>
#import "XcodeInterfaces.h"

@interface XMASXcodeRepository : NSObject

- (NSMenu *)menuWithTitle:(NSString *)title;

- (id)currentEditor;
- (NSRange)cursorSelectionRange;

- (XC(IDEWorkspaceWindowController))currentWorkspaceController;
- (XC(Workspace))currentWorkspace;

- (NSArray *)targetsInCurrentWorkspace;

- (NSURL *)currentSourceCodeDocumentFileURL;

- (XC(IDEIndex))indexForCurrentWorkspace;

- (id)callableSymbolKind;
- (id)instanceMethodSymbolKind;
- (NSArray *)instanceMethodSymbolsInWorkspace;

- (NSArray *)geniusCallerResultsForEditorContext:(id)editorContext;

@end

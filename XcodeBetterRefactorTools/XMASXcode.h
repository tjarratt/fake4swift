#import <Cocoa/Cocoa.h>
#import "XcodeInterfaces.h"

@interface XMASXcode : NSObject 
+ (NSMenu *)menuWithTitle:(NSString *)title;
@end

@interface XMASXcode (Workspace)

+ (id)currentEditor;
+ (XC(IDEWorkspaceWindowController))currentWorkspaceController;
+ (XC(Workspace))currentWorkspace;
+ (NSURL *)currentSourceCodeDocumentFileURL;
+ (XC(IDEDocumentController))sharedDocumentController;
+ (XC(IDEIndex))indexForCurrentWorkspace;

@end

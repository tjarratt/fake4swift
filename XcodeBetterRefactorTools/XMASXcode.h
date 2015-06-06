#import <Cocoa/Cocoa.h>
#import "XcodeInterfaces.h"

@interface XMASXcode : NSObject 
+ (NSMenu *)menuWithTitle:(NSString *)title;
@end

@interface XMASXcode (Workspace)
+ (XC(IDEWorkspaceWindowController))currentWorkspaceController;
+ (XC(Workspace))currentWorkspace;
+ (id)currentEditor;
+ (NSURL *)currentSourceCodeDocumentFileURL;
@end

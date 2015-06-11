#import <Cocoa/Cocoa.h>
#import "XMASObjcSelector.h"

@interface XMASChangeMethodSignatureController : NSWindowController

- (void)refactorMethod:(XMASObjcSelector *)method inFile:(NSString *)filePath;

@end

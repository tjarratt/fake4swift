#import <Cocoa/Cocoa.h>
#import "XMASObjcSelector.h"

@interface XMASChangeMethodSignatureController : NSViewController

@property (nonatomic, weak, readonly) NSWindow *window;
@property (nonatomic, weak, readonly) NSTableView *tableView;

- (instancetype)initWithWindow:(NSWindow *)window;
- (void)refactorMethod:(XMASObjcSelector *)method inFile:(NSString *)filePath;

@end

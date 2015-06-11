#import "XMASChangeMethodSignatureController.h"

@interface XMASChangeMethodSignatureController ()
@property (nonatomic) NSWindow *refactorMethodWindow;
@end

@implementation XMASChangeMethodSignatureController

- (instancetype)initWithWindow:(NSWindow *)window {
    if (self = [super initWithWindow:window]) {
        self.refactorMethodWindow = window;
    }

    return self;
}

- (void)refactorMethod:(XMASObjcSelector *)method inFile:(NSString *)filePath
{
    [self.refactorMethodWindow makeKeyAndOrderFront:NSApp];
}

@end

#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASChangeMethodSignatureController.h"
#import "XMASWindowProvider.h"

static XMASChangeMethodSignatureController *controller;

@interface XMASChangeMethodSignatureControllerProvider ()
@property (nonatomic) XMASWindowProvider *windowProvider;
@end

@implementation XMASChangeMethodSignatureControllerProvider

- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider {
    if (self = [super init]) {
        self.windowProvider = windowProvider;
    }

    return self;
}

- (XMASChangeMethodSignatureController *)provideInstance
{
    if (!controller) {
        NSWindow *window = self.windowProvider.provideInstance;
        controller = [[XMASChangeMethodSignatureController alloc] initWithWindow:window];
    }

    return controller;
}

@end

#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASChangeMethodSignatureController.h"
#import "XMASWindowProvider.h"

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

- (XMASChangeMethodSignatureController *)provideInstanceWithDelegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate {
    return [[XMASChangeMethodSignatureController alloc] initWithWindowProvider:self.windowProvider
                                                                      delegate:delegate];
}

@end

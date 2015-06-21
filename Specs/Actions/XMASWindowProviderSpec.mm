#import <Cedar/Cedar.h>
#import "XMASWindowProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASWindowProviderSpec)

describe(@"XMASWindowProvider", ^{
    __block XMASWindowProvider *subject;

    beforeEach(^{
        subject = [[XMASWindowProvider alloc] init];
    });

    it(@"should provide a window", ^{
        subject.provideInstance should be_instance_of([NSWindow class]);
    });

    it(@"should give the window a reasonable size", ^{
        NSWindow *window = subject.provideInstance;
        CGRectGetHeight(window.frame) should be_greater_than(0);
        CGRectGetHeight(window.frame) should be_greater_than(0);
    });
});

SPEC_END

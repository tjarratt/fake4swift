#import <Cedar/Cedar.h>
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASChangeMethodSignatureController.h"
#import "XMASWindowProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASChangeMethodSignatureControllerProviderSpec)

describe(@"XMASChangeMethodSignatureControllerProvider", ^{
    __block XMASChangeMethodSignatureControllerProvider *subject;
    __block XMASWindowProvider *windowProvider;
    NSWindow *window = nice_fake_for([NSWindow class]);

    beforeEach(^{
        windowProvider = nice_fake_for([XMASWindowProvider class]);
        windowProvider stub_method(@selector(provideInstance)).and_return(window);
        subject = [[XMASChangeMethodSignatureControllerProvider alloc] initWithWindowProvider:windowProvider];
    });

    describe(@"-provideInstance", ^{
        __block XMASChangeMethodSignatureController *controller;

        beforeEach(^{
            controller = subject.provideInstance;
        });

        it(@"should provide a change method signature controller", ^{
            controller should be_instance_of([XMASChangeMethodSignatureController class]);
        });

        it(@"should pass an NSWindow to its controller", ^{
            controller.window should be_same_instance_as(window);
        });

        it(@"should only provide a single instance", ^{
            controller should be_same_instance_as(subject.provideInstance);
        });
    });
});

SPEC_END

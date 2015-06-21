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
    windowProvider = nice_fake_for([XMASWindowProvider class]);

    beforeEach(^{
        subject = [[XMASChangeMethodSignatureControllerProvider alloc] initWithWindowProvider:windowProvider];
    });

    describe(@"-provideInstance", ^{
        __block XMASChangeMethodSignatureController *controller;
        __block id<XMASChangeMethodSignatureControllerDelegate> delegate;

        beforeEach(^{
            delegate = nice_fake_for(@protocol(XMASChangeMethodSignatureControllerDelegate));
            controller = [subject provideInstanceWithDelegate:delegate];
        });

        it(@"should provide a change method signature controller", ^{
            controller should be_instance_of([XMASChangeMethodSignatureController class]);
        });

        it(@"should pass its delegate to the controller", ^{
            controller.delegate should be_same_instance_as(delegate);
        });

        it(@"should pass an NSWindow provider to its controller", ^{
            controller.windowProvider should be_same_instance_as(windowProvider);
        });
    });
});

SPEC_END

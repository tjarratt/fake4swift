#import <Cedar/Cedar.h>
#import "XMASChangeMethodSignatureController.h"
#import "XMASObjcSelector.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASChangeMethodSignatureControllerSpec)

describe(@"XMASChangeMethodSignatureController", ^{
    __block NSWindow *window;
    __block XMASChangeMethodSignatureController *subject;

    beforeEach(^{
        window = nice_fake_for([NSWindow class]);
        subject = [[XMASChangeMethodSignatureController alloc] initWithWindow:window];
    });

    describe(@"-refactorMethod:inFile:", ^{
        __block XMASObjcSelector *method;
        __block NSString *filepath;

        beforeEach(^{
            method = nice_fake_for([XMASObjcSelector class]);
            filepath = @"/tmp/imagine.all.the.people";
            [subject refactorMethod:method inFile:filepath];
        });

        it(@"should make the window key and visible", ^{
            window should have_received(@selector(makeKeyAndOrderFront:)).with(NSApp);
        });
    });
});

SPEC_END

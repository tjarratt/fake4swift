#import <Cedar/Cedar.h>
#import "XMASEditMenu.h"
#import "XMASRefactorMethodActionProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASEditMenuSpec)

describe(@"XMASEditMenu", ^{
    __block XMASEditMenu *subject;
    __block XMASRefactorMethodActionProvider *actionProvider;

    beforeEach(^{
        actionProvider = nice_fake_for([XMASRefactorMethodActionProvider class]);
        subject = [[XMASEditMenu alloc] initWithRefactorMethodActionProvider:actionProvider];
    });

    describe(@"-refactorCurrentMethodAction:", ^{
        beforeEach(^{
            [subject refactorCurrentMethodAction:nil];
        });

        it(@"should ask its provider for an XMASRefactorMethodAction", ^{
            actionProvider should have_received(@selector(provideInstanceWithEditor:alerter:controllerProvider:methodDeclParser:));
        });
    });
});

SPEC_END

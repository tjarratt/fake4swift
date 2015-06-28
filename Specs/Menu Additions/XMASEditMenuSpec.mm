#import <Cedar/Cedar.h>
#import "XMASEditMenu.h"
#import "XMASRefactorMethodActionProvider.h"
#import "XMASRefactorMethodAction.h"

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
        __block XMASRefactorMethodAction *action;

        beforeEach(^{
            action = nice_fake_for([XMASRefactorMethodAction class]);
            actionProvider stub_method(@selector(provideInstanceWithEditor:alerter:controllerProvider:methodDeclParser:))
                .and_return(action);
            [subject refactorCurrentMethodAction:nil];
        });

        it(@"should ask its provider for an XMASRefactorMethodAction", ^{
            actionProvider should have_received(@selector(provideInstanceWithEditor:alerter:controllerProvider:methodDeclParser:));
        });

        it(@"should attempt to safely refactor the method under the cursor", ^{
            action should have_received(@selector(safelyRefactorMethodUnderCursor));
        });
    });
});

SPEC_END

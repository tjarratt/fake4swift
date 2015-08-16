#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "XMASEditMenu.h"
#import "XMASRefactorMethodAction.h"
#import "RefactorToolsModule.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASEditMenuSpec)

describe(@"XMASEditMenu", ^{
    __block XMASEditMenu *subject;
    __block id<BSInjector, BSBinder> injector;

    beforeEach(^{
        injector = (id)[Blindside injectorWithModule:[[RefactorToolsModule alloc] init]];
        subject = [[XMASEditMenu alloc] initWithInjector:injector];
    });

    describe(@"-refactorCurrentMethodAction:", ^{
        __block XMASRefactorMethodAction *action;

        beforeEach(^{
            action = nice_fake_for([XMASRefactorMethodAction class]);
            [injector bind:[XMASRefactorMethodAction class] toInstance:action];

            [subject refactorCurrentMethodAction:nil];
        });

        it(@"should attempt to safely refactor the method under the cursor", ^{
            action should have_received(@selector(safelyRefactorMethodUnderCursor));
        });
    });
});

SPEC_END

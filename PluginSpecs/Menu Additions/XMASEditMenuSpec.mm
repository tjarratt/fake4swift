#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import <BetterRefactorToolsKit/BetterRefactorToolsKit.h>
#import <BetterRefactorToolsKit/BetterRefactorToolsKit-Swift.h>

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

    describe(@"generating a test double for a swift protocol", ^{
        __block XMASGenerateFakeForSwiftProtocolUseCase *useCase;

        beforeEach(^{
            useCase = nice_fake_for([XMASGenerateFakeForSwiftProtocolUseCase class]);
            [injector bind:[XMASGenerateFakeForSwiftProtocolUseCase class] toInstance:useCase];

            [subject generateFakeAction:nil];
        });

        it(@"should attempt to safely generate a fake for the selected swift protocol", ^{
            useCase should have_received(@selector(safelyGenerateFakeForSelectedProtocol));
        });
    });

    describe(@"implementing equatable for a swift struct", ^{
        __block XMASImplementEquatableUseCase *useCase;

        beforeEach(^{
            useCase = nice_fake_for([XMASImplementEquatableUseCase class]);
            [injector bind:[XMASImplementEquatableUseCase class] toInstance:useCase];

            [subject implementEquatableAction:nil];
        });

        it(@"should attempt to safely implement equatable for the selected swift struct", ^{
            useCase should have_received(@selector(safelyAddEquatableToSelectedStruct));
        });
    });
});

SPEC_END

#import <Cedar/Cedar.h>
#import "XMASRefactorMethodAction.h"
#import "XcodeInterfaces.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASChangeMethodSignatureController.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASAlert.h"
#import "XMASTokenizer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASRefactorMethodActionSpec)

describe(@"XMASRefactorMethodAction", ^{
    __block XMASRefactorMethodAction *subject;
    __block id editor;
    __block XMASAlert *alerter;
    __block XMASTokenizer *tokenizer;
    __block XMASObjcMethodDeclarationParser *methodDeclParser;
    __block NSRange cursorRange;
    __block XMASChangeMethodSignatureControllerProvider *controllerProvider;

    beforeEach(^{
        alerter = nice_fake_for([XMASAlert class]);
        editor = nice_fake_for(@protocol(XCP(IDESourceCodeEditor)));
        tokenizer = nice_fake_for([XMASTokenizer class]);
        controllerProvider = nice_fake_for([XMASChangeMethodSignatureControllerProvider class]);
        methodDeclParser = nice_fake_for([XMASObjcMethodDeclarationParser class]);
        subject = [[XMASRefactorMethodAction alloc] initWithAlerter:alerter
                                                          tokenizer:tokenizer
                                                 controllerProvider:controllerProvider
                                                   methodDeclParser:methodDeclParser];
        [subject setupWithEditor:editor];
    });

    __block XMASObjcMethodDeclaration *methodDeclaration;

    void (^refactorMethodUnderCursor)() = ^void() {
        NSURL *fileURL = [[NSURL alloc] initWithString:@"file:///tmp/fixture.swift"];
        id sourceCodeDocument = nice_fake_for(@protocol(XMASXcode_IDESourceCodeDocument));
        sourceCodeDocument stub_method(@selector(fileURL)).and_return(fileURL);
        editor stub_method(@selector(sourceCodeDocument)).and_return(sourceCodeDocument);

        NSArray *tokens = @[];
        tokenizer stub_method(@selector(tokensForFilePath:))
            .with(@"/tmp/fixture.swift")
            .and_return(tokens);

        methodDeclaration = nice_fake_for([XMASObjcMethodDeclaration class]);
        methodDeclaration stub_method(@selector(range)).and_return(NSMakeRange(5, 15));
        methodDeclaration stub_method(@selector(selectorString)).and_return(@"initWithThis:andThat:");
        methodDeclParser stub_method(@selector(parseMethodDeclarationsFromTokens:))
            .with(tokens)
            .and_return(@[methodDeclaration]);

        id location = nice_fake_for(@protocol(XCP(DVTTextDocumentLocation)));
        location stub_method(@selector(characterRange)).and_return(cursorRange);
        editor stub_method(@selector(currentSelectedDocumentLocations)).and_return(@[location]);

        [subject safelyRefactorMethodUnderCursor];
    };

    describe(@"when the cursor is inside of a method declaration", ^{
        __block XMASChangeMethodSignatureController *controller;

        beforeEach(^{
            controller = nice_fake_for([XMASChangeMethodSignatureController class]);
            controllerProvider stub_method(@selector(provideInstanceWithDelegate:)).and_return(controller);

            cursorRange = NSMakeRange(10, 1);

            refactorMethodUnderCursor();
        });

        it(@"should make itself the delegate of the controller", ^{
            controllerProvider should have_received(@selector(provideInstanceWithDelegate:))
                .with(subject);
        });

        it(@"should show the selector of the current method under the cursor", ^{
            alerter should_not have_received(@selector(flashMessage:));
        });

        it(@"should present a change method signature controller", ^{
            controller should have_received(@selector(refactorMethod:inFile:))
                .with(methodDeclaration)
                .and_with(@"/tmp/fixture.swift");
        });

        describe(@"as a <XMASChangeMethodSignatureControllerDelegate>", ^{
            beforeEach(^{
                [subject refactorMethodUnderCursor];
            });

            it(@"should hold a reference to the controller", ^{
                subject.controller should be_same_instance_as(controller);
            });

            describe(@"when the controller will go away", ^{
                it(@"should no longer have a reference to its controller", ^{
                    [subject controllerWillDisappear:controller];
                    subject.controller should be_nil;
                });
            });
        });
    });

    describe(@"when the cursor is not inside of a method declaration", ^{
        beforeEach(^{
            cursorRange = NSMakeRange(100, 1);
            refactorMethodUnderCursor();
        });

        it(@"alert the user", ^{
            alerter should have_received(@selector(flashMessage:)).with(noMethodSelected);
        });
    });

    context(@"when an exception is raised while refactoring a method", ^{
        __block NSException *exception;
        __block XMASChangeMethodSignatureController<CedarDouble> *controller;

        beforeEach(^{
            controller = nice_fake_for([XMASChangeMethodSignatureController class]);
            controllerProvider stub_method(@selector(provideInstanceWithDelegate:)).and_return(controller);
            cursorRange = NSMakeRange(10, 1);

            exception = nice_fake_for([NSException class]);
            controller stub_method(@selector(refactorMethod:inFile:)).and_raise_exception(exception);
        });

        it(@"should alert the user that the action failed", ^{
            refactorMethodUnderCursor();
            alerter should have_received(@selector(flashComfortingMessageForException:))
                .with(exception);
        });
    });
});

SPEC_END

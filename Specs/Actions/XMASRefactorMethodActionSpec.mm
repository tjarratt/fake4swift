#import <Cedar/Cedar.h>
#import <ClangKit/ClangKit.h>
#import "XMASRefactorMethodAction.h"
#import "XcodeInterfaces.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASChangeMethodSignatureController.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASAlert.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASRefactorMethodActionSpec)

describe(@"XMASRefactorMethodAction", ^{
    __block XMASRefactorMethodAction *subject;
    __block id editor;
    __block XMASAlert *alerter;
    __block XMASObjcMethodDeclarationParser *methodDeclParser;
    __block NSRange cursorRange;
    __block XMASChangeMethodSignatureControllerProvider *controllerProvider;

    beforeEach(^{
        alerter = nice_fake_for([XMASAlert class]);
        editor = nice_fake_for(@protocol(XCP(IDESourceCodeEditor)));
        controllerProvider = nice_fake_for([XMASChangeMethodSignatureControllerProvider class]);
        methodDeclParser = nice_fake_for([XMASObjcMethodDeclarationParser class]);
        subject = [[XMASRefactorMethodAction alloc] initWithAlerter:alerter
                                                 controllerProvider:controllerProvider
                                                   methodDeclParser:methodDeclParser];
        [subject setupWithEditor:editor];
    });

    __block XMASObjcMethodDeclaration *selector;

    void (^refactorMethodUnderCursor)() = ^void() {
        NSURL *fileURL = [[NSURL alloc] initWithString:@"file:///tmp/fixture.swift"];
        id sourceCodeDocument = nice_fake_for(@protocol(XMASXcode_IDESourceCodeDocument));
        sourceCodeDocument stub_method(@selector(fileURL)).and_return(fileURL);
        editor stub_method(@selector(sourceCodeDocument)).and_return(sourceCodeDocument);

        NSArray *tokens = @[];
        CKTranslationUnit *translationUnit = nice_fake_for([CKTranslationUnit class]);
        translationUnit stub_method(@selector(tokens)).and_return(tokens);
        spy_on([CKTranslationUnit class]);
        [CKTranslationUnit class] stub_method(@selector(translationUnitWithPath:))
            .with(@"/tmp/fixture.swift")
            .and_return(translationUnit);

        selector = nice_fake_for([XMASObjcMethodDeclaration class]);
        selector stub_method(@selector(range)).and_return(NSMakeRange(5, 15));
        selector stub_method(@selector(selectorString)).and_return(@"initWithThis:andThat:");
        NSArray *methodDeclarations = @[selector];
        methodDeclParser stub_method(@selector(parseMethodDeclarationsFromTokens:))
            .with(tokens)
            .and_return(methodDeclarations);

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
                .with(selector)
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

        afterEach(^{
            stop_spying_on([CKTranslationUnit class]);
        });

        it(@"alert the user", ^{
            alerter should have_received(@selector(flashMessage:)).with(noMethodSelected);
        });
    });

    describe(@"-safelyRefactorMethod:", ^{
        __block NSException *exception;
        __block XMASChangeMethodSignatureController<CedarDouble> *controller;

        beforeEach(^{
            controller = nice_fake_for([XMASChangeMethodSignatureController class]);
            controllerProvider stub_method(@selector(provideInstanceWithDelegate:)).and_return(controller);
            cursorRange = NSMakeRange(10, 1);

            exception = nice_fake_for([NSException class]);
            controller stub_method(@selector(refactorMethod:inFile:)).and_raise_exception(exception);
        });

        it(@"should capture the exception", ^{
            ^{ refactorMethodUnderCursor(); } should_not raise_exception();
        });

        it(@"should alert the user that the action failed", ^{
            refactorMethodUnderCursor();
            alerter should have_received(@selector(flashComfortingMessageForException:))
                .with(exception);
        });
    });
});

SPEC_END

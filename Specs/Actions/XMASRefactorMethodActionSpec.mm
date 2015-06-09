#import <Cedar/Cedar.h>
#import <ClangKit/ClangKit.h>
#import "XMASRefactorMethodAction.h"
#import "XcodeInterfaces.h"
#import "XMASAlert.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASObjcSelector.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASRefactorMethodActionSpec)

describe(@"XMASRefactorMethodAction", ^{
    __block XMASRefactorMethodAction *subject;
    __block id editor;
    __block XMASAlert *alerter;
    __block XMASObjcMethodDeclarationParser *methodDeclParser;
    __block NSRange cursorRange;

    beforeEach(^{
        alerter = nice_fake_for([XMASAlert class]);
        editor = nice_fake_for(@protocol(XCP(IDESourceCodeEditor)));
        methodDeclParser = nice_fake_for([XMASObjcMethodDeclarationParser class]);
        subject = [[XMASRefactorMethodAction alloc] initWithEditor:editor
                                                           alerter:alerter
                                                  methodDeclParser:methodDeclParser];
    });

    subjectAction(^{
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

        XMASObjcSelector *selector = nice_fake_for([XMASObjcSelector class]);
        selector stub_method(@selector(range)).and_return(NSMakeRange(5, 15));
        selector stub_method(@selector(selectorString)).and_return(@"initWithThis:andThat:");
        NSArray *methodDeclarations = @[selector];
        methodDeclParser stub_method(@selector(parseMethodDeclarationsFromTokens:))
            .with(tokens)
            .and_return(methodDeclarations);

        id location = nice_fake_for(@protocol(XCP(DVTTextDocumentLocation)));
        location stub_method(@selector(characterRange)).and_return(cursorRange);
        editor stub_method(@selector(currentSelectedDocumentLocations)).and_return(@[location]);

        [subject refactorMethodUnderCursor];
    });

    describe(@"when the cursor is inside of a method declaration", ^{
        beforeEach(^{
            cursorRange = NSMakeRange(10, 1);
        });

        it(@"should show the selector of the current method under the cursor", ^{
            alerter should have_received(@selector(flashMessage:)).with(@"initWithThis:andThat:");
        });
    });

    describe(@"when the cursor is not inside of a method declaration", ^{
        beforeEach(^{
            cursorRange = NSMakeRange(100, 1);
        });

        afterEach(^{
            stop_spying_on([CKTranslationUnit class]);
        });

        it(@"alert the user", ^{
            alerter should have_received(@selector(flashMessage:)).with(noMethodSelected);
        });
    });
});

SPEC_END

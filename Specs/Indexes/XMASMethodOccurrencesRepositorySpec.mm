#import <Cedar/Cedar.h>
#import "XMASMethodOccurrencesRepository.h"
#import "XMASXcode.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XcodeInterfaces.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASMethodOccurrencesRepositorySpec)

describe(@"XMASMethodOccurrencesRepository", ^{
    __block XMASMethodOccurrencesRepository *subject;
    __block XC(IDEWorkspaceWindowController) workspaceWindowController;

    beforeEach(^{
        spy_on([XMASXcode class]);
        workspaceWindowController = nice_fake_for(@protocol(XCP(IDEWorkspaceWindowController)));
        subject = [[XMASMethodOccurrencesRepository alloc] initWithWorkspaceWindowController:workspaceWindowController];
    });

    afterEach(^{
        stop_spying_on([XMASXcode class]);
    });

    describe(@"-callExpressionsMatchingSelector:", ^{
        __block id editorArea;
        __block id editorContext;

        __block NSDictionary *geniusResult;
        __block XC(IDEIndexSymbol) expectedResult;

        beforeEach(^{
            expectedResult = nice_fake_for(@protocol(XCP(IDEIndexSymbol)));
            geniusResult = @{@"calleeSymbolOccurrence" : expectedResult};

            editorContext = [[NSObject alloc] init];
            editorArea = nice_fake_for(@protocol(XCP(IDEEditorArea)));
            editorArea stub_method(@selector(lastActiveEditorContext)).and_return(editorContext);
            workspaceWindowController stub_method(@selector(editorArea)).and_return(editorArea);

            [XMASXcode class] stub_method(@selector(geniusCallerResultsForEditorContext:))
                .with(editorContext)
                .and_return(@[geniusResult]);
        });

        it(@"should filter the call expressions to only those matching the selector", ^{
            NSArray *results = [subject callSitesOfCurrentlySelectedMethod];
            results.count should equal(1);
            results.firstObject should be_same_instance_as(expectedResult);
        });
    });
});

SPEC_END

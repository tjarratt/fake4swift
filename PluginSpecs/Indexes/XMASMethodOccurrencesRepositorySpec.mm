#import <Cedar/Cedar.h>
#import "XMASMethodOccurrencesRepository.h"
#import "XMASXcodeRepository.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XcodeInterfaces.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASMethodOccurrencesRepositorySpec)

describe(@"XMASMethodOccurrencesRepository", ^{
    __block XMASMethodOccurrencesRepository *subject;
    __block XMASXcodeRepository *xcodeRepository;
    __block XC(IDEWorkspaceWindowController) workspaceWindowController;

    beforeEach(^{
        xcodeRepository = nice_fake_for([XMASXcodeRepository class]);
        workspaceWindowController = nice_fake_for(@protocol(XCP(IDEWorkspaceWindowController)));
        subject = [[XMASMethodOccurrencesRepository alloc] initWithWorkspaceWindowController:workspaceWindowController
                   xcodeRepository:xcodeRepository];
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

            xcodeRepository stub_method(@selector(geniusCallerResultsForEditorContext:))
                .with(editorContext)
                .and_return(@[geniusResult]);
        });

        it(@"should filter the call expressions to only those matching the selector", ^{
            NSSet *results = [subject callSitesOfCurrentlySelectedMethod];
            results.count should equal(1);
            results should contain(expectedResult);
        });
    });

    describe(@"-forwardDeclarationsOfMethod:", ^{
        __block NSArray *workspaceSymbols;
        __block XC(IDEIndexSymbol) matchingIndexSymbol;

        beforeEach(^{
            matchingIndexSymbol = nice_fake_for(@protocol(XCP(IDEIndexSymbol)));
            matchingIndexSymbol stub_method(@selector(name)).and_return(@"initWithThis:andThat:");

            XC(IDEIndexSymbol) nonMatchingIndexSymbol = nice_fake_for(@protocol(XCP(IDEIndexSymbol)));
            nonMatchingIndexSymbol stub_method(@selector(name)).and_return(@"garbage");

            workspaceSymbols = @[matchingIndexSymbol, nonMatchingIndexSymbol];
            xcodeRepository stub_method(@selector(instanceMethodSymbolsInWorkspace)).and_return(workspaceSymbols);
        });

        it(@"should only return matching forward declarations for the method provided", ^{
            XMASObjcMethodDeclaration *methodDeclaration = nice_fake_for([XMASObjcMethodDeclaration class]);
            methodDeclaration stub_method(@selector(selectorString)).and_return(@"initWithThis:andThat:");

            NSSet *forwardDeclarations = [subject forwardDeclarationsOfMethod:methodDeclaration];
            forwardDeclarations.count should equal(1);
            forwardDeclarations should contain(matchingIndexSymbol);
        });
    });
});

SPEC_END

#import <Cedar/Cedar.h>
#import "XMASIndexedSymbolRepository.h"
#import "XMASXcode.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XcodeInterfaces.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASIndexedSymbolRepositorySpec)

describe(@"XMASIndexedSymbolRepository", ^{
    __block XMASIndexedSymbolRepository *subject;
    __block XC(IDEWorkspaceWindowController) workspaceWindowController;

    beforeEach(^{
        spy_on([XMASXcode class]);
        subject = [[XMASIndexedSymbolRepository alloc] initWithWorkspaceWindowController:workspaceWindowController];
    });

    afterEach(^{
        stop_spying_on([XMASXcode class]);
    });

    describe(@"-callExpressionsMatchingSelector:", ^{
        __block XMASObjcMethodDeclaration *selector;
        __block id editorArea;
        __block id editorContext;

        NSDictionary *expectedResult = @{@"name": @"method:"};
        NSArray *allSymbols = @[expectedResult, @{@"name": @"not:the:method:"}];

        beforeEach(^{
            selector = nice_fake_for([XMASObjcMethodDeclaration class]);
            selector stub_method(@selector(selectorString)).and_return(@"method:");

            editorContext = [[NSObject alloc] init];
            editorArea = nice_fake_for(@protocol(XCP(IDEEditorArea)));
            editorArea stub_method(@selector(lastActiveEditorContext)).and_return(editorContext);

            [XMASXcode class] stub_method(@selector(geniusCallerResultsForEditorContext:))
                .with(editorContext)
                .and_return(allSymbols);
        });

        fit(@"should filter the call expressions to only those matching the selector", ^{
            NSArray *results = [subject callExpressionsMatchingSelector:selector];
            results.count should equal(1);
            results.firstObject should be_same_instance_as(expectedResult);
        });
    });
});

SPEC_END

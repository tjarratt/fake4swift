#import <Cedar/Cedar.h>
#import "XMASIndexedSymbolRepository.h"
#import "XMASXcode.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASIndexedSymbolRepositorySpec)

describe(@"XMASIndexedSymbolRepository", ^{
    __block XMASIndexedSymbolRepository *subject;

    beforeEach(^{
        subject = [[XMASIndexedSymbolRepository alloc] init];
    });

    describe(@"-callExpressionsMatchingSelector:", ^{
        __block XMASObjcMethodDeclaration *selector;
        __block id<XMASXcode_IDEIndex> fakeIndex;
        __block id fakeSymbolKind;
        NSDictionary *expectedResult = @{@"name": @"method:"};
        NSArray *allSymbols = @[expectedResult, @{@"name": @"not:the:method:"}];

        beforeEach(^{
            selector = nice_fake_for([XMASObjcMethodDeclaration class]);
            selector stub_method(@selector(selectorString)).and_return(@"method:");
            fakeIndex = nice_fake_for(@protocol(XMASXcode_IDEIndex));
            fakeSymbolKind = [[NSObject alloc] init];

            spy_on([XMASXcode class]);
            [XMASXcode class] stub_method(@selector(instanceMethodSymbolKind))
                .and_return(fakeSymbolKind);
            [XMASXcode class] stub_method(@selector(indexForCurrentWorkspace))
                .and_return(fakeIndex);
            fakeIndex stub_method(@selector(allSymbolsMatchingKind:workspaceOnly:))
                .with(fakeSymbolKind, YES).and_return(allSymbols);
        });

        afterEach(^{
            stop_spying_on([XMASXcode class]);
        });

        it(@"should filter the call expressions to only those matching the selector", ^{
            NSArray *results = [subject callExpressionsMatchingSelector:selector];
            results.count should equal(1);
            results.firstObject should be_same_instance_as(expectedResult);
        });
    });
});

SPEC_END

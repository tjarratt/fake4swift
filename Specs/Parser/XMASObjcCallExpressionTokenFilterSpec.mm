#import <Cedar/Cedar.h>
#import <ClangKit/ClangKit.h>
#import "XMASObjcCallExpressionTokenFilter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcCallExpressionTokenFilterSpec)

describe(@"XMASObjcCallExpressionTokenFilter", ^{
    NSString *methodDeclarationFixture = [[NSBundle mainBundle] pathForResource:@"methodDeclaration" ofType:@"m"];
    NSArray *methodDeclarationTokens = [[CKTranslationUnit translationUnitWithPath:methodDeclarationFixture] tokens];

    describe(@"-parseAllCallExpressionsFromTokens:", ^{
        XMASObjcCallExpressionTokenFilter *subject = [[XMASObjcCallExpressionTokenFilter alloc] init];
        it(@"should parse the range of each call expression in the array of tokens", ^{
            NSSet *callExprRanges = [subject parseCallExpressionRangesFromTokens:methodDeclarationTokens];
            callExprRanges should equal([NSSet setWithObjects:
                                         [NSValue valueWithRange:NSMakeRange(53, 22)],
                                         [NSValue valueWithRange:NSMakeRange(54, 8)],
                                         [NSValue valueWithRange:NSMakeRange(76, 6)],
                                         [NSValue valueWithRange:NSMakeRange(83, 4)],
                                         nil]);
        });
    });
});

SPEC_END

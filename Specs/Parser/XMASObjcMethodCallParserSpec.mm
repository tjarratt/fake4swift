#import <Cedar/Cedar.h>
#import <ClangKit/ClangKit.h>

#import "XMASObjcMethodCallParser.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcMethodCallParserSpec)

describe(@"XMASObjcMethodCallparser", ^{
    XMASObjcMethodCallParser *subject = [[XMASObjcMethodCallParser alloc] init];


    describe(@"parsing method calls from a stream of tokens", ^{
        NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"methodDeclaration" ofType:@"m"];
        CKTranslationUnit *translationUnit = [CKTranslationUnit translationUnitWithPath:fixturePath];

        NSString *selector = @"initWithIcon:message:parentWindow:duration:";
        NSArray *methodCalls = [subject parseMethodCallsFromTokens:translationUnit.tokens matchingSelector:selector];

        fit(@"should only find the one matching method call", ^{
            methodCalls.count should equal(1);
        });
    });
});

SPEC_END

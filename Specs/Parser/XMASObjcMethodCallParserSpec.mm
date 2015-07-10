#import <Cedar/Cedar.h>
#import <ClangKit/ClangKit.h>

#import "XMASObjcMethodCallParser.h"
#import "XMASObjcMethodCall.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcMethodCallParserSpec)

describe(@"XMASObjcMethodCallParser", ^{
    XMASObjcMethodCallParser *subject = [[XMASObjcMethodCallParser alloc] init];

    describe(@"parsing method calls from a stream of tokens", ^{
        NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"methodDeclaration" ofType:@"m"];
        CKTranslationUnit *translationUnit = [CKTranslationUnit translationUnitWithPath:fixturePath];

        NSString *selector = @"initWithIcon:message:parentWindow:duration:";
        NSArray *initWithMethodCalls = [subject parseMethodCallsFromTokens:translationUnit.tokens
                                                          matchingSelector:selector
                                                                    inFile:fixturePath];

        it(@"should only find the one matching method call", ^{
            initWithMethodCalls.count should equal(1);
        });

        it(@"should return an ObjcMethodCall", ^{
            XMASObjcMethodCall *methodCall = initWithMethodCalls.firstObject;
            methodCall should be_instance_of([XMASObjcMethodCall class]);
            methodCall.range should equal(NSMakeRange(277, 281));
            methodCall.selectorString should equal(selector);
            methodCall.selectorComponents should equal(@[@"initWithIcon", @"message", @"parentWindow", @"duration"]);
            methodCall.arguments should equal(@[@"nil", @"message", @"nil", @"2.0"]);
            methodCall.filePath should equal(fixturePath);
        });
    });
});

SPEC_END

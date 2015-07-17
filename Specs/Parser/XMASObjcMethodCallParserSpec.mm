#import <Cedar/Cedar.h>
#import <ClangKit/ClangKit.h>

#import "XMASObjcMethodCallParser.h"
#import "XMASObjcMethodCall.h"
#import "XMASObjcCallExpressionTokenFilter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcMethodCallParserSpec)

describe(@"XMASObjcMethodCallParser", ^{
    __block XMASObjcMethodCallParser *subject;
    __block XMASObjcCallExpressionTokenFilter *callExpressionTokenFilter;

    NSString *methodDeclarationFixture = [[NSBundle mainBundle] pathForResource:@"methodDeclaration" ofType:@"m"];
    NSArray *methodDeclarationTokens = [[CKTranslationUnit translationUnitWithPath:methodDeclarationFixture] tokens];

    NSString *nestedCallExpressionsFixture = [[NSBundle mainBundle] pathForResource:@"NestedCallExpressions" ofType:@"m"];
    NSArray *nestedCallExpressionTokens = [[CKTranslationUnit translationUnitWithPath:nestedCallExpressionsFixture] tokens];

    beforeEach(^{
        callExpressionTokenFilter = [[XMASObjcCallExpressionTokenFilter alloc] init];
        subject = [[XMASObjcMethodCallParser alloc] initWithCallExpressionTokenFilter:callExpressionTokenFilter];
    });

    describe(@"-matchingCallExpressions", ^{
        context(@"matching a simple initWithThis:andThat: selector", ^{
            __block NSArray *initWithMethodCalls;
            NSString *selector = @"initWithIcon:message:parentWindow:duration:";

            beforeEach(^{
                [subject setupWithSelectorToMatch:selector filePath:methodDeclarationFixture andTokens:methodDeclarationTokens];

                initWithMethodCalls = subject.matchingCallExpressions;
            });

            it(@"should only find the one matching method call", ^{
                initWithMethodCalls.count should equal(1);
            });

            it(@"should return an ObjcMethodCall", ^{
                XMASObjcMethodCall *methodCall = initWithMethodCalls.firstObject;
                methodCall should be_instance_of([XMASObjcMethodCall class]);
                methodCall.target should equal(@"[NSClassFromString(@\"DVTBezelAlertPanel\") alloc]");
                methodCall.selectorString should equal(selector);
                methodCall.selectorComponents should equal(@[@"initWithIcon", @"message", @"parentWindow", @"duration"]);
                methodCall.arguments should equal(@[@"nil", @"message", @"nil", @"2.0"]);
                methodCall.filePath should equal(methodDeclarationFixture);
                methodCall.range should equal(NSMakeRange(277, 281));
                methodCall.lineNumber should equal(14);
                methodCall.columnNumber should equal(71);
            });
        });

        xcontext(@"with nested call expressions as arguments to another call expression", ^{
            __block NSArray *matchingCallExpressions;
            NSString *selector = @"myFoo:";

            beforeEach(^{
                [subject setupWithSelectorToMatch:selector filePath:nestedCallExpressionsFixture andTokens:nestedCallExpressionTokens];
                matchingCallExpressions = subject.matchingCallExpressions;
            });

            it(@"should find all of the matching call expressions", ^{
                matchingCallExpressions.count should equal(4);
            });

            it(@"should return an ObjcMethodCall for each call site", ^{
                XMASObjcMethodCall *methodCall = matchingCallExpressions.firstObject;
                methodCall.range should equal(NSMakeRange(861, 7));
                methodCall.selectorString should equal(selector);
                methodCall.selectorComponents should equal(@[@"myFoo"]);
                methodCall.arguments should equal(@[@"1"]);
                methodCall.filePath should equal(nestedCallExpressionsFixture);
                methodCall.lineNumber should equal(28);
                methodCall.columnNumber should equal(49);

                methodCall = matchingCallExpressions[1];
                methodCall should be_instance_of([XMASObjcMethodCall class]);
                methodCall.range should equal(NSMakeRange(918, 7));
                methodCall.selectorString should equal(selector);
                methodCall.selectorComponents should equal(@[@"myFoo"]);
                methodCall.arguments should equal(@[@"2"]);
                methodCall.filePath should equal(nestedCallExpressionsFixture);
                methodCall.lineNumber should equal(29);
                methodCall.columnNumber should equal(49);

                methodCall = matchingCallExpressions[2];
                methodCall should be_instance_of([XMASObjcMethodCall class]);
                methodCall.range should equal(NSMakeRange(975, 7));
                methodCall.selectorString should equal(selector);
                methodCall.selectorComponents should equal(@[@"myFoo"]);
                methodCall.arguments should equal(@[@"3"]);
                methodCall.filePath should equal(nestedCallExpressionsFixture);
                methodCall.lineNumber should equal(30);
                methodCall.columnNumber should equal(49);

                methodCall = matchingCallExpressions[3];
                methodCall should be_instance_of([XMASObjcMethodCall class]);
                methodCall.range should equal(NSMakeRange(1032, 7));
                methodCall.selectorString should equal(selector);
                methodCall.selectorComponents should equal(@[@"myFoo"]);
                methodCall.arguments should equal(@[@"4"]);
                methodCall.filePath should equal(nestedCallExpressionsFixture);
                methodCall.lineNumber should equal(31);
                methodCall.columnNumber should equal(49);
            });
        });
    });
});

SPEC_END

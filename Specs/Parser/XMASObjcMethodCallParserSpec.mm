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

    NSString *methodDeclarationFixture = [[NSBundle mainBundle] pathForResource:@"MethodDeclaration" ofType:@"m"];
    NSArray *methodDeclarationTokens = [[CKTranslationUnit translationUnitWithPath:methodDeclarationFixture] tokens];

    NSString *nestedCallExpressionsFixture = [[NSBundle mainBundle] pathForResource:@"NestedCallExpressions" ofType:@"m"];
    NSArray *nestedCallExpressionTokens = [[CKTranslationUnit translationUnitWithPath:nestedCallExpressionsFixture] tokens];

    NSString *nilArgumentFixture = [[NSBundle mainBundle] pathForResource:@"RefactorMethodFixture" ofType:@"m"];
    NSArray *nilArgumentTokens = [[CKTranslationUnit translationUnitWithPath:nilArgumentFixture] tokens];

    beforeEach(^{
        callExpressionTokenFilter = [[XMASObjcCallExpressionTokenFilter alloc] init];
        subject = [[XMASObjcMethodCallParser alloc] initWithCallExpressionTokenFilter:callExpressionTokenFilter];
    });

    describe(@"-matchingCallExpressions", ^{
        context(@"matching a simple initWithThis:andThat: selector", ^{
            __block NSArray *initWithMethodCalls;
            NSString *selector = @"initWithIcon:message:parentWindow:duration:";

            beforeEach(^{
                [subject setupWithSelectorToMatch:selector
                                         filePath:methodDeclarationFixture
                                        andTokens:methodDeclarationTokens];

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
                methodCall.range should equal(NSMakeRange(227, 332));
                methodCall.lineNumber should equal(14);
                methodCall.columnNumber should equal(71);
            });
        });

        context(@"with a call expression whose arguments are sometimes nil", ^{
            __block NSArray *matchingCallExpressions;
            NSString *selector = @"initWithIcon:message:parentWindow:duration:";

            beforeEach(^{
                [subject setupWithSelectorToMatch:selector
                                         filePath:nilArgumentFixture
                                        andTokens:nilArgumentTokens];
                matchingCallExpressions = subject.matchingCallExpressions;
            });

            it(@"should find the correct call expression", ^{
                NSArray *components = @[@"initWithIcon", @"message", @"parentWindow", @"duration"];
                NSArray *arguments = @[@"nil", @"message", @"nil", @"2.0"];
                XMASObjcMethodCall *expectedCallExpr = [[XMASObjcMethodCall alloc] initWithSelectorComponents:components
                                                                                                 columnNumber:49
                                                                                                   lineNumber:4
                                                                                                    arguments:arguments
                                                                                                     filePath:nilArgumentFixture
                                                                                                       target:@"[DVTBezelAlertPanel alloc]"
                                                                                                        range:NSMakeRange(123, 244)];
                matchingCallExpressions should equal(@[expectedCallExpr]);
            });
        });

        context(@"with nested call expressions as arguments to another call expression", ^{
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
                XMASObjcMethodCall *expectedCallExpr = [[XMASObjcMethodCall alloc] initWithSelectorComponents:@[@"myFoo"]
                                                                                                 columnNumber:49
                                                                                                   lineNumber:28
                                                                                                    arguments:@[@"1"]
                                                                                                     filePath:nestedCallExpressionsFixture
                                                                                                       target:@"Foo"
                                                                                                        range:NSMakeRange(856, 13)];
                matchingCallExpressions should contain(expectedCallExpr);

                expectedCallExpr = [[XMASObjcMethodCall alloc] initWithSelectorComponents:@[@"myFoo"]
                                                                             columnNumber:49
                                                                               lineNumber:29
                                                                                arguments:@[@"2"]
                                                                                 filePath:nestedCallExpressionsFixture
                                                                                   target:@"Foo"
                                                                                    range:NSMakeRange(913, 13)];
                matchingCallExpressions should contain(expectedCallExpr);

                expectedCallExpr = [[XMASObjcMethodCall alloc] initWithSelectorComponents:@[@"myFoo"]
                                                                             columnNumber:49
                                                                               lineNumber:30
                                                                                arguments:@[@"3"]
                                                                                 filePath:nestedCallExpressionsFixture
                                                                                   target:@"Foo"
                                                                                    range:NSMakeRange(970, 13)];
                matchingCallExpressions should contain(expectedCallExpr);

                expectedCallExpr = [[XMASObjcMethodCall alloc] initWithSelectorComponents:@[@"myFoo"]
                                                                             columnNumber:49
                                                                               lineNumber:31
                                                                                arguments:@[@"4"]
                                                                                 filePath:nestedCallExpressionsFixture
                                                                                   target:@"Foo"
                                                                                    range:NSMakeRange(1027, 13)];
                matchingCallExpressions should contain(expectedCallExpr);
            });
        });
    });
});

SPEC_END

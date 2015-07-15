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
            methodCall.target should equal(@"[NSClassFromString(@\"DVTBezelAlertPanel\") alloc]");
            methodCall.selectorString should equal(selector);
            methodCall.selectorComponents should equal(@[@"initWithIcon", @"message", @"parentWindow", @"duration"]);
            methodCall.arguments should equal(@[@"nil", @"message", @"nil", @"2.0"]);
            methodCall.filePath should equal(fixturePath);
            methodCall.range should equal(NSMakeRange(277, 281));
            methodCall.lineNumber should equal(14);
            methodCall.columnNumber should equal(71);
        });
    });

    xdescribe(@"parsing nested method calls", ^{
        NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"NestedCallExpressions" ofType:@"m"];
        CKTranslationUnit *translationUnit = [CKTranslationUnit translationUnitWithPath:fixturePath];

        NSString *selector = @"myFoo:";
        NSArray *matchingCallExpressions = [subject parseMethodCallsFromTokens:translationUnit.tokens
                                                              matchingSelector:selector
                                                                        inFile:fixturePath];

        it(@"should find all of the matching call expressions", ^{
            matchingCallExpressions.count should equal(4);
        });

        it(@"should return an ObjcMethodCall for each call site", ^{
            XMASObjcMethodCall *methodCall = matchingCallExpressions[0];
            methodCall should be_instance_of([XMASObjcMethodCall class]);
            methodCall.range should equal(NSMakeRange(861, 7));
            methodCall.selectorString should equal(selector);
            methodCall.selectorComponents should equal(@[@"myFoo"]);
            methodCall.arguments should equal(@[@"1"]);
            methodCall.filePath should equal(fixturePath);
            methodCall.lineNumber should equal(28);
            methodCall.columnNumber should equal(49);

            methodCall = matchingCallExpressions[1];
            methodCall should be_instance_of([XMASObjcMethodCall class]);
            methodCall.range should equal(NSMakeRange(918, 7));
            methodCall.selectorString should equal(selector);
            methodCall.selectorComponents should equal(@[@"myFoo"]);
            methodCall.arguments should equal(@[@"2"]);
            methodCall.filePath should equal(fixturePath);
            methodCall.lineNumber should equal(29);
            methodCall.columnNumber should equal(49);

            methodCall = matchingCallExpressions[2];
            methodCall should be_instance_of([XMASObjcMethodCall class]);
            methodCall.range should equal(NSMakeRange(975, 7));
            methodCall.selectorString should equal(selector);
            methodCall.selectorComponents should equal(@[@"myFoo"]);
            methodCall.arguments should equal(@[@"3"]);
            methodCall.filePath should equal(fixturePath);
            methodCall.lineNumber should equal(30);
            methodCall.columnNumber should equal(49);

            methodCall = matchingCallExpressions[3];
            methodCall should be_instance_of([XMASObjcMethodCall class]);
            methodCall.range should equal(NSMakeRange(1032, 7));
            methodCall.selectorString should equal(selector);
            methodCall.selectorComponents should equal(@[@"myFoo"]);
            methodCall.arguments should equal(@[@"4"]);
            methodCall.filePath should equal(fixturePath);
            methodCall.lineNumber should equal(31);
            methodCall.columnNumber should equal(49);
        });
    });
});

SPEC_END

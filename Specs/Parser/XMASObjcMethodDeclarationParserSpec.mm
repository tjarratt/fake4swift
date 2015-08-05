#import <Cedar/Cedar.h>
#import <ClangKit/ClangKit.h>

#import "XMASObjcMethodDeclarationParser.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcMethodDeclarationParserSpec)

describe(@"XMASObjcMethodDeclarationParser", ^{
    XMASObjcMethodDeclarationParser *subject = [[XMASObjcMethodDeclarationParser alloc] init];

    describe(@"parsing a stream of ClangKit tokens for a .m file", ^{
        NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"MethodDeclaration" ofType:@"m"];
        CKTranslationUnit *translationUnit = [CKTranslationUnit translationUnitWithPath:fixturePath];
        NSArray *methodDeclarations = [subject parseMethodDeclarationsFromTokens:translationUnit.tokens];

        it(@"should have a method declaration for each method", ^{
            NSArray *expectedMethods = @[@"flashMessage:", @"hideMessage", @"flashMessage:", @"hideMessage", @"tap:", @"performAction:"];
            [methodDeclarations valueForKey:@"selectorString"] should equal(expectedMethods);
        });

        describe(@"the first method declaration", ^{
            __block XMASObjcMethodDeclaration *selector;

            beforeEach(^{
                selector = methodDeclarations[0];
            });

            it(@"should have the correct return type", ^{
                selector.returnType should equal(@"void");
            });

            it(@"should have the correct range for its tokens", ^{
                selector.range should equal(NSMakeRange(60, 40));
            });

            it(@"should have the correct line number", ^{
                selector.lineNumber should equal(5);
            });

            it(@"should have the correct column number", ^{
                selector.columnNumber should equal(1);
            });

            describe(@"parameters", ^{
                __block XMASObjcMethodDeclarationParameter *param;

                beforeEach(^{
                    param = selector.parameters.firstObject;
                });

                it(@"should only have a single parameter", ^{
                    selector.parameters.count should equal(1);
                });

                it(@"should have the correct parameter type", ^{
                    param.type should equal(@"NSString *");
                });

                it(@"should have the correct name", ^{
                    param.localName should equal(@"message");
                });
            });
        });

        describe(@"the second method declaration", ^{
            __block XMASObjcMethodDeclaration *selector;

            beforeEach(^{
                selector = [methodDeclarations objectAtIndex:1];
            });

            it(@"should not have any parameters", ^{
                selector.parameters should be_empty;
            });

            it(@"should have the correct range for its tokens", ^{
                selector.range should equal(NSMakeRange(102, 25));
            });

            it(@"should have the correct return type", ^{
                selector.returnType should equal(@"NSString *");
            });

            it(@"should have the correct line number", ^{
                selector.lineNumber should equal(6);
            });

            it(@"should have the correct column number", ^{
                selector.columnNumber should equal(1);
            });
        });

        describe(@"the third method declaration", ^{
            __block XMASObjcMethodDeclaration *selector;

            beforeEach(^{
                selector = methodDeclarations[2];
            });

            it(@"should have the correct return type", ^{
                selector.returnType should equal(@"void");
            });

            it(@"should have the correct range for its tokens", ^{
                selector.range should equal(NSMakeRange(164, 40));
            });

            it(@"should have the correct line number", ^{
                selector.lineNumber should equal(13);
            });

            it(@"should have the correct column number", ^{
                selector.columnNumber should equal(1);
            });

            describe(@"parameters", ^{
                __block XMASObjcMethodDeclarationParameter *param;

                beforeEach(^{
                    param = selector.parameters.firstObject;
                });

                it(@"should only have a single parameter", ^{
                    selector.parameters.count should equal(1);
                });

                it(@"should have the correct parameter type", ^{
                    param.type should equal(@"NSString *");
                });

                it(@"should have the correct name", ^{
                    param.localName should equal(@"message");
                });
            });
        });

        describe(@"the fourth method declaration", ^{
            __block XMASObjcMethodDeclaration *selector;

            beforeEach(^{
                selector = [methodDeclarations objectAtIndex:3];
            });

            it(@"should not have any parameters", ^{
                selector.parameters should be_empty;
            });

            it(@"should have the correct range for its tokens", ^{
                selector.range should equal(NSMakeRange(623, 25));
            });

            it(@"should have the correct return type", ^{
                selector.returnType should equal(@"NSString *");
            });

            it(@"should have the correct line number", ^{
                selector.lineNumber should equal(22);
            });

            it(@"should have the correct column number", ^{
                selector.columnNumber should equal(1);
            });
        });

        describe(@"the fifth method declaration", ^{
            __block XMASObjcMethodDeclaration *selector;

            beforeEach(^{
                selector = [methodDeclarations objectAtIndex:4];
            });

            it(@"should have one parameter", ^{
                selector.parameters.count should equal(1);
            });

            it(@"should have the correct range for its tokens", ^{
                selector.range should equal(NSMakeRange(670, 26));
            });

            it(@"should have the correct return type", ^{
                selector.returnType should equal(@"IBAction");
            });

            it(@"should have the correct line number", ^{
                selector.lineNumber should equal(26);
            });

            it(@"should have the correct column number", ^{
                selector.columnNumber should equal(1);
            });
        });

        describe(@"the sixth method declaration", ^{
            __block XMASObjcMethodDeclaration *selector;

            beforeEach(^{
                selector = [methodDeclarations objectAtIndex:5];
            });

            it(@"should have one parameter", ^{
                selector.parameters.count should equal(1);
                [selector.parameters.firstObject type] should equal(@"id<NSObject>");

                [selector.parameters.firstObject localName] should equal(@"action");
            });

            it(@"should have the correct selector string", ^{
                selector.selectorString should equal(@"performAction:");
            });

            it(@"should have the correct range for its tokens", ^{
                selector.range should equal(NSMakeRange(707, 42));
            });

            it(@"should have the correct return type", ^{
                selector.returnType should equal(@"void");
            });

            it(@"should have the correct line number", ^{
                selector.lineNumber should equal(30);
            });

            it(@"should have the correct column number", ^{
                selector.columnNumber should equal(1);
            });
        });
    });

    describe(@"parsing a stream of ClangKit tokens for a header", ^{
        NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"RefactorMethodFixture" ofType:@"h"];
        NSString *fixtureContents = [NSString stringWithContentsOfFile:fixturePath
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];

        CKTranslationUnit *translationUnit = [CKTranslationUnit translationUnitWithText:fixtureContents
                                                                               language:CKLanguageObjC];
        NSArray *methodDeclarations = [subject parseMethodDeclarationsFromTokens:translationUnit.tokens];

        it(@"should have a method declaration for each method", ^{
            NSArray *expectedMethods = @[@"initWithThis:", @"flashMessage:"];
            [methodDeclarations valueForKey:@"selectorString"] should equal(expectedMethods);
        });
    });
});

SPEC_END

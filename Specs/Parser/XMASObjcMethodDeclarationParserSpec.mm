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

    describe(@"parsing a collection of tokens from ClangKit", ^{
        NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"MethodDeclaration" ofType:@"m"];
        CKTranslationUnit *translationUnit = [CKTranslationUnit translationUnitWithPath:fixturePath];
        NSArray *methodDeclarations = [subject parseMethodDeclarationsFromTokens:translationUnit.tokens];

        it(@"should have a method declaration for each method", ^{
            NSArray *expectedMethods = @[@"flashMessage:", @"hideMessage", @"flashMessage:", @"hideMessage", @"tap:"];
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
        });
    });
});

SPEC_END

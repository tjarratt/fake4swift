#import <Cedar/Cedar.h>
#import "XMASObjcMethodDeclaration.h"
#import <ClangKit/ClangKit.h>
#import "XMASObjcMethodDeclarationParameter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcMethodDeclarationSpec)

describe(@"XMASObjcMethodDeclaration", ^{
    __block XMASObjcMethodDeclaration *subject;
    __block CKToken *instanceMethod;
    __block CKToken *returnType;
    __block CKToken *colon;
    __block CKToken *openParen;
    __block CKToken *closeParen;
    __block CKToken *star;

    beforeEach(^{
        instanceMethod = nice_fake_for([CKToken class]);
        instanceMethod stub_method(@selector(spelling)).and_return(@"-");
        instanceMethod stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);
        instanceMethod stub_method(@selector(range)).and_return(NSMakeRange(10, 20));

        returnType = nice_fake_for([CKToken class]);
        returnType stub_method(@selector(spelling)).and_return(@"void");
        returnType stub_method(@selector(kind)).and_return(CKTokenKindKeyword);

        colon = nice_fake_for([CKToken class]);
        colon stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);

        openParen = nice_fake_for([CKToken class]);
        openParen stub_method(@selector(spelling)).and_return(@"(");
        openParen stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);

        star = nice_fake_for([CKToken class]);
        star stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);
        star stub_method(@selector(spelling)).and_return(@"*");

        closeParen = nice_fake_for([CKToken class]);
        closeParen stub_method(@selector(spelling)).and_return(@")");
        closeParen stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);
    });

    describe(@"a selector with no args", ^{
        beforeEach(^{
            CKToken *selectorName = nice_fake_for([CKToken class]);
            selectorName stub_method(@selector(spelling)).and_return(@"initWithNothing");
            selectorName stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);
            selectorName stub_method(@selector(range)).and_return(NSMakeRange(50, 20));

            subject = [[XMASObjcMethodDeclaration alloc] initWithTokens:@[instanceMethod, openParen, returnType, closeParen, selectorName]];
        });

        it(@"should create the correct selector from its tokens", ^{
            subject.selectorString should equal(@"initWithNothing");
            subject.parameters should be_empty();
        });

        it(@"should have the correct return type", ^{
            subject.returnType should equal(@"void");
        });

        it(@"should have the correct range for its tokens", ^{
            subject.range should equal(NSMakeRange(10, 60));
        });

        it(@"should have a single component", ^{
            subject.components should equal(@[@"initWithNothing"]);
        });
    });

    void(^createSelectorWithSeveralParameters)() = ^void() {
        CKToken *firstSelectorPiece = nice_fake_for([CKToken class]);
        firstSelectorPiece stub_method(@selector(spelling)).and_return(@"initWithThis");
        firstSelectorPiece stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);
        firstSelectorPiece stub_method(@selector(range)).and_return(NSMakeRange(0, 12));

        CKToken *firstParamType = nice_fake_for([CKToken class]);
        firstParamType stub_method(@selector(spelling)).and_return(@"NSString");
        firstParamType stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);
        firstParamType stub_method(@selector(range)).and_return(NSMakeRange(50, 8));

        star stub_method(@selector(range)).and_return(NSMakeRange(59, 1));

        CKToken *firstVariableName = nice_fake_for([CKToken class]);
        firstVariableName stub_method(@selector(spelling)).and_return(@"firstThing");
        firstVariableName stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

        CKToken *secondSelectorPieceToken = nice_fake_for([CKToken class]);
        secondSelectorPieceToken stub_method(@selector(spelling)).and_return(@"andThat");
        secondSelectorPieceToken stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

        CKToken *secondParamType = nice_fake_for([CKToken class]);
        secondParamType stub_method(@selector(spelling)).and_return(@"MyClassName");
        secondParamType stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

        CKToken *secondVariableName = nice_fake_for([CKToken class]);
        secondVariableName stub_method(@selector(spelling)).and_return(@"secondThing");
        secondVariableName stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);
        secondVariableName stub_method(@selector(range)).and_return(NSMakeRange(100, 11));

        NSArray *tokens = @[
                            instanceMethod, openParen, returnType, closeParen,
                            firstSelectorPiece, colon,
                            openParen, firstParamType, star, closeParen, firstVariableName,
                            secondSelectorPieceToken, colon,
                            openParen, secondParamType, closeParen, secondVariableName
                            ];
        subject = [[XMASObjcMethodDeclaration alloc] initWithTokens:tokens];
    };

    describe(@"a selector with several parameters and a non-void return type", ^{
        beforeEach(^{
            createSelectorWithSeveralParameters();
        });

        it(@"should create the correct selector from its token", ^{
            subject.selectorString should equal(@"initWithThis:andThat:");
        });

        it(@"should have the correct number of parameters", ^{
            subject.parameters.count should equal(2);
        });

        it(@"should have the correct range for its tokens", ^{
            subject.range should equal(NSMakeRange(10, 101));
        });

        it(@"should have a component for each part of the selector", ^{
            subject.components should equal(@[@"initWithThis", @"andThat"]);
        });

        describe(@"the first parameter", ^{
            __block XMASObjcMethodDeclarationParameter *param;

            beforeEach(^{
                param = subject.parameters.firstObject;
                param should be_instance_of([XMASObjcMethodDeclarationParameter class]);
            });

            it(@"should have the correct type", ^{
                param.type should equal(@"NSString *");
            });

            it(@"should have the correct local name", ^{
                param.localName should equal(@"firstThing");
            });
        });

        describe(@"the second parameter", ^{
            __block XMASObjcMethodDeclarationParameter *param;

            beforeEach(^{
                param = subject.parameters[1];
                param should be_instance_of([XMASObjcMethodDeclarationParameter class]);
            });

            it(@"should have the correct type", ^{
                param.type should equal(@"MyClassName");
            });

            it(@"should have the correct local name", ^{
                param.localName should equal(@"secondThing");
            });
        });
    });

    describe(@"creating a new selector", ^{
        __block XMASObjcMethodDeclaration *newSelector;

        beforeEach(^{
            createSelectorWithSeveralParameters();
        });

        context(@"by deleting a component", ^{
            beforeEach(^{
                newSelector = [subject deleteComponentAtIndex:1];
            });

            it(@"should create the correct selector from its token", ^{
                newSelector.selectorString should equal(@"initWithThis:");
            });

            it(@"should have the correct number of parameters", ^{
                newSelector.parameters.count should equal(1);
            });

            it(@"should have the correct range for its tokens", ^{
                newSelector.range should equal(NSMakeRange(10, 101));
            });

            it(@"should have a component for each part of the selector", ^{
                newSelector.components should equal(@[@"initWithThis"]);
            });

            describe(@"the first parameter", ^{
                __block XMASObjcMethodDeclarationParameter *param;

                beforeEach(^{
                    param = newSelector.parameters.firstObject;
                    param should be_instance_of([XMASObjcMethodDeclarationParameter class]);
                });

                it(@"should have the correct type", ^{
                    param.type should equal(@"NSString *");
                });
                
                it(@"should have the correct local name", ^{
                    param.localName should equal(@"firstThing");
                });
            });
        });

        context(@"by adding a component", ^{
            beforeEach(^{
                newSelector = [subject insertComponentAtIndex:1];
            });

            it(@"should create the correct selector from its token", ^{
                newSelector.selectorString should equal(@"initWithThis::andThat:");
            });

            it(@"should have the correct number of parameters", ^{
                newSelector.parameters.count should equal(3);
            });

            it(@"should have the correct range for its tokens", ^{
                newSelector.range should equal(NSMakeRange(10, 101));
            });

            it(@"should have a component for each part of the selector", ^{
                newSelector.components should equal(@[@"initWithThis", @"", @"andThat"]);
            });

            describe(@"the first parameter", ^{
                __block XMASObjcMethodDeclarationParameter *param;

                beforeEach(^{
                    param = newSelector.parameters.firstObject;
                    param should be_instance_of([XMASObjcMethodDeclarationParameter class]);
                });

                it(@"should have the correct type", ^{
                    param.type should equal(@"NSString *");
                });

                it(@"should have the correct local name", ^{
                    param.localName should equal(@"firstThing");
                });
            });

            describe(@"the second parameter", ^{
                __block XMASObjcMethodDeclarationParameter *param;

                beforeEach(^{
                    param = newSelector.parameters[1];
                    param should be_instance_of([XMASObjcMethodDeclarationParameter class]);
                });

                it(@"should have the correct type", ^{
                    param.type should equal(@"");
                });

                it(@"should have the correct local name", ^{
                    param.localName should equal(@"");
                });
            });

            describe(@"the third parameter", ^{
                __block XMASObjcMethodDeclarationParameter *param;

                beforeEach(^{
                    param = newSelector.parameters[2];
                    param should be_instance_of([XMASObjcMethodDeclarationParameter class]);
                });

                it(@"should have the correct type", ^{
                    param.type should equal(@"MyClassName");
                });

                it(@"should have the correct local name", ^{
                    param.localName should equal(@"secondThing");
                });
            });
        });

        context(@"by swapping two componenets", ^{
            beforeEach(^{
                newSelector = [subject swapComponentAtIndex:0 withComponentAtIndex:1];
            });

            it(@"should create the correct selector from its token", ^{
                newSelector.selectorString should equal(@"initWithThat:andThis:");
            });

            it(@"should have the correct number of parameters", ^{
                newSelector.parameters.count should equal(2);
            });

            it(@"should have the correct range for its tokens", ^{
                newSelector.range should equal(NSMakeRange(10, 101));
            });

            it(@"should have a component for each part of the selector", ^{
                newSelector.components should equal(@[@"initWithThat", @"andThis"]);
            });

            describe(@"the first parameter", ^{
                __block XMASObjcMethodDeclarationParameter *param;

                beforeEach(^{
                    param = newSelector.parameters[0];
                    param should be_instance_of([XMASObjcMethodDeclarationParameter class]);
                });

                it(@"should have the correct type", ^{
                    param.type should equal(@"MyClassName");
                });

                it(@"should have the correct local name", ^{
                    param.localName should equal(@"secondThing");
                });
            });

            describe(@"the second parameter", ^{
                __block XMASObjcMethodDeclarationParameter *param;

                beforeEach(^{
                    param = newSelector.parameters[1];
                    param should be_instance_of([XMASObjcMethodDeclarationParameter class]);
                });

                it(@"should have the correct type", ^{
                    param.type should equal(@"NSString *");
                });

                it(@"should have the correct local name", ^{
                    param.localName should equal(@"firstThing");
                });
            });
        });

        context(@"by swapping two components", ^{
            beforeEach(^{
                newSelector = [subject swapComponentAtIndex:1 withComponentAtIndex:0];
            });

            it(@"should create the correct selector from its token", ^{
                newSelector.selectorString should equal(@"initWithThat:andThis:");
            });

            it(@"should have the correct number of parameters", ^{
                newSelector.parameters.count should equal(2);
            });

            it(@"should have the correct range for its tokens", ^{
                newSelector.range should equal(NSMakeRange(10, 101));
            });

            it(@"should have a component for each part of the selector", ^{
                newSelector.components should equal(@[@"initWithThat", @"andThis"]);
            });

            describe(@"the first parameter", ^{
                __block XMASObjcMethodDeclarationParameter *param;

                beforeEach(^{
                    param = newSelector.parameters[0];
                    param should be_instance_of([XMASObjcMethodDeclarationParameter class]);
                });

                it(@"should have the correct type", ^{
                    param.type should equal(@"MyClassName");
                });

                it(@"should have the correct local name", ^{
                    param.localName should equal(@"secondThing");
                });
            });

            describe(@"the second parameter", ^{
                __block XMASObjcMethodDeclarationParameter *param;

                beforeEach(^{
                    param = newSelector.parameters[1];
                    param should be_instance_of([XMASObjcMethodDeclarationParameter class]);
                });

                it(@"should have the correct type", ^{
                    param.type should equal(@"NSString *");
                });

                it(@"should have the correct local name", ^{
                    param.localName should equal(@"firstThing");
                });
            });
        });

        context(@"by changing the name of a selector component", ^{
            beforeEach(^{
                newSelector = [subject changeSelectorNameAtIndex:0 to:@"butts"];
            });

            it(@"should yield a new copy with the selector name changed at the provided index", ^{
                newSelector.selectorString should equal(@"butts:andThat:");
            });
        });

        context(@"by changing the type of a parameter", ^{
            beforeEach(^{
                newSelector = [subject changeParameterTypeAtIndex:0 to:@"Butts *"];
            });

            it(@"should yield a new copy with the selector name changed at the provided index", ^{
                [newSelector.parameters[0] type] should equal(@"Butts *");
            });
        });

        context(@"by changing the local name of an argument", ^{
            beforeEach(^{
                newSelector = [subject changeParameterLocalNameAtIndex:0 to:@"butts"];
            });

            it(@"should yield a new copy with the selector name changed at the provided index", ^{
                [newSelector.parameters[0] localName] should equal(@"butts");
            });
        });
    });
});

SPEC_END

#import <Cedar/Cedar.h>
#import "XMASObjcSelector.h"
#import <ClangKit/ClangKit.h>
#import "XMASObjcSelectorParameter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcSelectorSpec)

describe(@"XMASObjcSelector", ^{
    __block XMASObjcSelector *subject;
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

            subject = [[XMASObjcSelector alloc] initWithTokens:@[instanceMethod, openParen, returnType, closeParen, selectorName]];
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
    });

    describe(@"a selector with several args and a return type", ^{
        beforeEach(^{
            CKToken *firstSelectorPiece = nice_fake_for([CKToken class]);
            firstSelectorPiece stub_method(@selector(spelling)).and_return(@"initWithThis");
            firstSelectorPiece stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

            CKToken *firstParamType = nice_fake_for([CKToken class]);
            firstParamType stub_method(@selector(spelling)).and_return(@"NSString");
            firstParamType stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

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
            subject = [[XMASObjcSelector alloc] initWithTokens:tokens];
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

        describe(@"the first parameter", ^{
            __block XMASObjcSelectorParameter *param;

            beforeEach(^{
                param = subject.parameters.firstObject;
                param should be_instance_of([XMASObjcSelectorParameter class]);
            });

            it(@"should have the correct type", ^{
                param.type should equal(@"NSString *");
            });

            it(@"should have the correct local name", ^{
                param.localName should equal(@"firstThing");
            });
        });

        describe(@"the second parameter", ^{
            __block XMASObjcSelectorParameter *param;

            beforeEach(^{
                param = subject.parameters[1];
                param should be_instance_of([XMASObjcSelectorParameter class]);
            });

            it(@"should have the correct type", ^{
                param.type should equal(@"MyClassName");
            });

            it(@"should have the correct local name", ^{
                param.localName should equal(@"secondThing");
            });
        });
    });
});

SPEC_END

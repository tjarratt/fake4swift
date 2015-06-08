#import <Cedar/Cedar.h>
#import "XMASObjcSelector.h"
#import <ClangKit/ClangKit.h>
#import "XMASObjcSelectorParameter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcSelectorSpec)

describe(@"XMASObjcSelector", ^{
    __block XMASObjcSelector *subject;

    describe(@"a selector with no args", ^{
        beforeEach(^{
            CKToken *token = nice_fake_for([CKToken class]);
            token stub_method(@selector(spelling)).and_return(@"initWithNothing");
            token stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

            subject = [[XMASObjcSelector alloc] initWithTokens:@[token]];
        });

        it(@"should create the correct selector from its token", ^{
            subject.selectorString should equal(@"initWithNothing");
            subject.parameters should be_empty();
        });
    });

    describe(@"a selector with several args", ^{
        beforeEach(^{
            CKToken *firstSelectorPieceToken = nice_fake_for([CKToken class]);
            firstSelectorPieceToken stub_method(@selector(spelling)).and_return(@"initWithThis");
            firstSelectorPieceToken stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

            CKToken *colonToken = nice_fake_for([CKToken class]);
            colonToken stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);

            CKToken *openParenToken = nice_fake_for([CKToken class]);
            openParenToken stub_method(@selector(spelling)).and_return(@"(");
            openParenToken stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);

            CKToken *firstParamTypeToken = nice_fake_for([CKToken class]);
            firstParamTypeToken stub_method(@selector(spelling)).and_return(@"NSString");
            firstParamTypeToken stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

            CKToken *starToken = nice_fake_for([CKToken class]);
            starToken stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);
            starToken stub_method(@selector(spelling)).and_return(@"*");

            CKToken *closeParenToken = nice_fake_for([CKToken class]);
            closeParenToken stub_method(@selector(spelling)).and_return(@")");
            closeParenToken stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);

            CKToken *firstVariableName = nice_fake_for([CKToken class]);
            firstVariableName stub_method(@selector(spelling)).and_return(@"firstThing");
            firstVariableName stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

            CKToken *secondSelectorPieceToken = nice_fake_for([CKToken class]);
            secondSelectorPieceToken stub_method(@selector(spelling)).and_return(@"andThat");
            secondSelectorPieceToken stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

            CKToken *secondParamTypeToken = nice_fake_for([CKToken class]);
            secondParamTypeToken stub_method(@selector(spelling)).and_return(@"MyClassName");
            secondParamTypeToken stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

            CKToken *secondVariableName = nice_fake_for([CKToken class]);
            secondVariableName stub_method(@selector(spelling)).and_return(@"secondThing");
            secondVariableName stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

            NSArray *tokens = @[
                                firstSelectorPieceToken, colonToken,
                                openParenToken, firstParamTypeToken, starToken, closeParenToken, firstVariableName,
                                secondSelectorPieceToken, colonToken,
                                openParenToken, secondParamTypeToken, closeParenToken, secondVariableName
                                ];
            subject = [[XMASObjcSelector alloc] initWithTokens:tokens];
        });

        it(@"should create the correct selector from its token", ^{
            subject.selectorString should equal(@"initWithThis:andThat:");
        });

        it(@"should have the correct number of parameters", ^{
            subject.parameters.count should equal(2);
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

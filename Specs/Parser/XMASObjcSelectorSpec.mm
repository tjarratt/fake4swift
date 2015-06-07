#import <Cedar/Cedar.h>
#import "XMASObjcSelector.h"
#import <ClangKit/ClangKit.h>

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

            CKToken *paramTypeToken = nice_fake_for([CKToken class]);
            paramTypeToken stub_method(@selector(spelling)).and_return(@"NSString *");
            paramTypeToken stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

            CKToken *starToken = nice_fake_for([CKToken class]);
            starToken stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);

            CKToken *closeParenToken = nice_fake_for([CKToken class]);
            closeParenToken stub_method(@selector(spelling)).and_return(@")");
            closeParenToken stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);

            CKToken *secondSelectorPieceToken = nice_fake_for([CKToken class]);
            secondSelectorPieceToken stub_method(@selector(spelling)).and_return(@"andThat");
            secondSelectorPieceToken stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

            NSArray *tokens = @[
                                firstSelectorPieceToken, colonToken,
                                openParenToken, paramTypeToken, starToken, closeParenToken,
                                secondSelectorPieceToken, colonToken,
                                openParenToken, paramTypeToken, starToken, closeParenToken,
                                ];
            subject = [[XMASObjcSelector alloc] initWithTokens:tokens];
        });

        it(@"should create the correct selector from its token", ^{
            subject.selectorString should equal(@"initWithThis:andThat:");
        });
    });
});

SPEC_END

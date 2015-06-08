#import <Cedar/Cedar.h>
#import <ClangKit/ClangKit.h>
#import "XMASObjcTypeParser.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcTypeParserSpec)

describe(@"XMASObjcTypeParser", ^{
    __block XMASObjcTypeParser *subject;

    beforeEach(^{
        subject = [[XMASObjcTypeParser alloc] init];
    });

    __block CKToken *starToken;
    __block CKToken *openParenToken;
    __block CKToken *closeParenToken;

    beforeEach(^{
        openParenToken = nice_fake_for([CKToken class]);
        openParenToken stub_method(@selector(spelling)).and_return(@"(;");
        openParenToken stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);

        starToken = nice_fake_for([CKToken class]);
        starToken stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);
        starToken stub_method(@selector(spelling)).and_return(@"*");

        closeParenToken = nice_fake_for([CKToken class]);
        closeParenToken stub_method(@selector(spelling)).and_return(@")");
        closeParenToken stub_method(@selector(kind)).and_return(CKTokenKindPunctuation);
    });

    describe(@"a pointer type", ^{
        __block NSString *type;

        beforeEach(^{
            CKToken *typeName = nice_fake_for([CKToken class]);
            typeName stub_method(@selector(spelling)).and_return(@"NSString");
            typeName stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

            NSArray *tokens = @[openParenToken, typeName, starToken, closeParenToken];
            type = [subject parseTypeFromTokens:tokens];
        });

        it(@"should be the correct type", ^{
            type should equal(@"NSString *");
        });
    });

    describe(@"a non-pointer type", ^{
        __block NSString *type;

        beforeEach(^{
            CKToken *typeName = nice_fake_for([CKToken class]);
            typeName stub_method(@selector(spelling)).and_return(@"id");
            typeName stub_method(@selector(kind)).and_return(CKTokenKindIdentifier);

            NSArray *tokens = @[openParenToken, typeName, closeParenToken];
            type = [subject parseTypeFromTokens:tokens];
        });

        it(@"should be the correct type", ^{
            type should equal(@"id");
        });
    });

    describe(@"a keyword type", ^{
        __block NSString *type;

        beforeEach(^{
            CKToken *typeName = nice_fake_for([CKToken class]);
            typeName stub_method(@selector(spelling)).and_return(@"void");
            typeName stub_method(@selector(kind)).and_return(CKTokenKindKeyword);

            NSArray *tokens = @[openParenToken, typeName, closeParenToken];
            type = [subject parseTypeFromTokens:tokens];
        });

        it(@"should be the correct type", ^{
            type should equal(@"void");
        });
    });
});

SPEC_END

#import <Cedar/Cedar.h>
#import <ClangKit/ClangKit.h>

#import "XMASObjcMethodDeclarationParser.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcMethodDeclarationParserSpec)

describe(@"XMASObjcMethodDeclarationParser", ^{
    __block XMASObjcMethodDeclarationParser *subject;

    beforeEach(^{
        subject = [[XMASObjcMethodDeclarationParser alloc] init];
    });

    describe(@"parsing a collection of tokens from ClangKit", ^{
        __block NSArray *methodDeclarations;

        beforeEach(^{
            NSString *fixturePath = [[NSBundle mainBundle] pathForResource:@"methodDeclaration" ofType:@"m"];
            CKTranslationUnit *translationUnit = [CKTranslationUnit translationUnitWithPath:fixturePath];
            methodDeclarations = [subject parseMethodDeclarationsFromTokens:translationUnit.tokens];
        });

        it(@"should have exactly two method declarations", ^{
            methodDeclarations.count should equal(2);
        });
    });
});

SPEC_END

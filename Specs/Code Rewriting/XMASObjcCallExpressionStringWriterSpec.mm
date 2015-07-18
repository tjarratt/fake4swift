#import <Cedar/Cedar.h>
#import "XMASObjcCallExpressionStringWriter.h"
#import "XMASObjcMethodDeclaration.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcCallExpressionStringWriterSpec)

describe(@"XMASObjcCallExpressionStringWriter", ^{
    __block XMASObjcCallExpressionStringWriter *subject;

    beforeEach(^{
        subject = [[XMASObjcCallExpressionStringWriter alloc] init];
    });

    describe(@"-callExpression:forTarget:withArgs:", ^{
        __block NSString *callExpressionString;

        beforeEach(^{
            NSArray *selectorComponents = @[@"setupWithName", @"floatValue", @"barValue"];
            XMASObjcMethodDeclaration *methodDeclaration = nice_fake_for([XMASObjcMethodDeclaration class]);
            methodDeclaration stub_method(@selector(components))
                .and_return(selectorComponents);
            NSArray *args = @[@"nil", @"1.0f", @"[Bar myBar]"];

            callExpressionString = [subject callExpression:methodDeclaration forTarget:@"[Foo myFoo]" withArgs:args];
        });

        it(@"should construct the correct call expression string", ^{
            callExpressionString should equal(@"[[Foo myFoo] setupWithName:nil floatValue:1.0f barValue:[Bar myBar]]");
        });
    });
});

SPEC_END

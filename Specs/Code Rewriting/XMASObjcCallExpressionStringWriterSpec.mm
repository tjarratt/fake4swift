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

    describe(@"-callExpression:forTarget:withArgs:atColumn:", ^{
        __block NSString *callExpressionString;

        beforeEach(^{
            NSArray *selectorComponents = @[@"setupWithName", @"floatValue", @"barValue"];
            XMASObjcMethodDeclaration *methodDeclaration = nice_fake_for([XMASObjcMethodDeclaration class]);
            methodDeclaration stub_method(@selector(components))
                .and_return(selectorComponents);
            NSArray *args = @[@"nil", @"1.0f", @"[Bar myBar]"];

            callExpressionString = [subject callExpression:methodDeclaration
                                                 forTarget:@"[Foo myFoo]"
                                                  withArgs:args
                                                  atColumn:13];
        });

        it(@"should construct the correct call expression string", ^{
            NSString *expectedString = @"[[Foo myFoo] setupWithName:nil\n"
                                       @"               floatValue:1.0f\n"
                                       @"                 barValue:[Bar myBar]]";
            callExpressionString should equal(expectedString);
        });
    });
});

SPEC_END

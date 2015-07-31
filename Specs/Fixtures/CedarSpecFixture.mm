#import <Cedar/Cedar.h>
#import "XMASObjcCallExpressionStringWriter.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcCallExpressionStringWriterSpec)

describe(@"XMASObjcCallExpressionStringWriter", ^{
    __block XMASObjcCallExpressionStringWriter *subject;

    beforeEach(^{
        subject = [[XMASObjcCallExpressionStringWriter alloc] init];
    });

    __block NSArray *selectorComponents;
    __block XMASObjcMethodDeclaration *methodDeclaration;
    __block NSArray *args;
    __block NSArray *parameters;

    beforeEach(^{
        selectorComponents = @[@"setupWithName", @"floatValue", @"barValue"];
        parameters = @[
                       [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"NSString *" localName:@"name"],
                       [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"CGFloat" localName:@"floatValue"],
                       [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"Bar *" localName:@"barValue"],
                       ];

        methodDeclaration = nice_fake_for([XMASObjcMethodDeclaration class]);
        methodDeclaration stub_method(@selector(components))
        .and_return(selectorComponents);
        methodDeclaration stub_method(@selector(returnType)).and_return(@"void");
        methodDeclaration stub_method(@selector(parameters))
        .and_return(parameters);

        args = @[@"nil", @"1.0f", @"[Bar myBar]"];
    });

    describe(@"-callExpression:forTarget:withArgs:atColumn:", ^{
        __block NSString *callExpressionString;

        beforeEach(^{
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

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
        it(@"should construct the correct string for a method with parameters", ^{
            NSString *callExpressionString = [subject callExpression:methodDeclaration
                                                           forTarget:@"[Foo myFoo]"
                                                            withArgs:args
                                                            atColumn:13];
            NSString *expectedString = @"[[Foo myFoo] setupWithName:nil\n"
            @"               floatValue:1.0f\n"
            @"                 barValue:[Bar myBar]]";
            callExpressionString should equal(expectedString);
        });

        it(@"should construct the correct string with a method without parameters", ^{
            methodDeclaration stub_method(@selector(components)).again().and_return(@[@"setupWithName"]);
            methodDeclaration stub_method(@selector(parameters)).again().and_return(@[]);

            NSString *result = [subject callExpression:methodDeclaration
                                             forTarget:@"subject"
                                              withArgs:@[]
                                              atColumn:13];

            NSString *expectedString = @"[subject setupWithName]";
            result should equal(expectedString);
        });
    });
});

SPEC_END

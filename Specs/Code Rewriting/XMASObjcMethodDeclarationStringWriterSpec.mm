#import <Cedar/Cedar.h>
#import "XMASObjcMethodDeclarationStringWriter.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcMethodDeclarationStringWriterSpec)

describe(@"XMASObjcMethodDeclarationStringWriter", ^{
    __block XMASObjcMethodDeclarationStringWriter *subject;

    __block NSArray *selectorComponents;
    __block XMASObjcMethodDeclaration *methodDeclaration;
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

        subject = [[XMASObjcMethodDeclarationStringWriter alloc] init];
    });

    describe(@"-formatInstanceMethodDeclaration:", ^{
        __block NSString *instanceMethodString;

        beforeEach(^{
            instanceMethodString = [subject formatInstanceMethodDeclaration:methodDeclaration];
        });

        it(@"should construct the correct declaration for the provided instance method", ^{
            NSString *expectedString = @"- (void)setupWithName:(NSString *)name\n"
            @"           floatValue:(CGFloat)floatValue\n"
            @"             barValue:(Bar *)barValue";
            instanceMethodString should equal(expectedString);
        });
    });
});

SPEC_END

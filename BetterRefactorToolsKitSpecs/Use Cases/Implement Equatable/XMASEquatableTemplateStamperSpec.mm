#import <Cedar/Cedar.h>

#import "BetterRefactorToolsKitSpecs-Swift.h"
#import "BetterRefactorToolsKitModule.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASEquatableTemplateStamperSpec)

describe(@"XMASEquatableTemplateStamper", ^{
    __block XMASEquatableTemplateStamper *subject;

    NSBundle *specBundle = [NSBundle mainBundle];
    NSString *fixturePath = [specBundle pathForResource:@"MySpecialStructEquatableExtension"
                                                 ofType:@"swift"];

    beforeEach(^{
        subject = [[XMASEquatableTemplateStamper alloc] initWithBundle:specBundle];
    });

    it(@"should provide a valid implementation of equatable for a struct", ^{
        NSError *error = nil;
        NSString *expectedImpl = [NSString stringWithContentsOfFile:fixturePath
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
        error should be_nil;

        StructDeclaration *specialStruct = [[StructDeclaration alloc] initWithName:@"MySpecialStruct"
                                                                          filePath:@"/fake/path"
                                                                            fields:@[@"name", @"age"]];
        error = nil;
        NSString *equatableImpl = [subject equatableImplementationForStruct:specialStruct
                                                                      error:&error];
        error should be_nil;
        expectedImpl should_not be_nil;
        equatableImpl should equal(expectedImpl);
    });
});

SPEC_END

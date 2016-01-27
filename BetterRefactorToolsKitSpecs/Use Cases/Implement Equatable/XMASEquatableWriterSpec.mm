#import <Cedar/Cedar.h>

#import "BetterRefactorToolsKitSpecs-Swift.h"
#import "BetterRefactorToolsKitModule.h"
#import "TempFileHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASEquatableWriterSpec)

describe(@"XMASEquatableWriter", ^{
    __block XMASEquatableWriter *subject;
    __block XMASEquatableTemplateStamper *templateStamper;

    NSBundle *specBundle = [NSBundle mainBundle];
    NSString *expectedFixture = [specBundle pathForResource:@"MySpecialStruct+Equatable"
                                                     ofType:@"swift"];

    NSString *temporaryFixturePath = [TempFileHelper temporaryFilePathForFixture:@"MySpecialStruct"
                                                                          ofType:@"swift"];

    beforeEach(^{
        templateStamper = [[XMASEquatableTemplateStamper alloc] initWithBundle:specBundle];
        subject = [[XMASEquatableWriter alloc] initWithTemplateStamper:templateStamper];
    });

    it(@"should rewrite a file to include an Equatable implementation", ^{
        StructDeclaration *myStruct = [[StructDeclaration alloc] initWithName:@"MySpecialStruct"
                                                                        range:NSMakeRange(10, 50)
                                                                     filePath:temporaryFixturePath
                                                                       fields:@[@"name", @"age"]];
        NSError *error = nil;
        [subject addEquatableImplForStruct:myStruct error:&error];

        error should be_nil;

        NSString *newFileContents = [NSString stringWithContentsOfFile:temporaryFixturePath
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];
        NSString *expectedContents = [NSString stringWithContentsOfFile:expectedFixture
                                                               encoding:NSUTF8StringEncoding
                                                                  error:nil];
        newFileContents should equal(expectedContents);
    });
});

SPEC_END

#import <Cedar/Cedar.h>
#import "XMASObjcMethodDeclarationRewriter.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XMASObjcMethodDeclarationStringWriter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcMethodDeclarationRewriterSpec)

describe(@"XMASObjcMethodDeclarationRewriter", ^{
    __block XMASObjcMethodDeclarationRewriter *subject;
    __block XMASObjcMethodDeclarationStringWriter *methodDeclarationStringWriter;

    beforeEach(^{
        methodDeclarationStringWriter = [[XMASObjcMethodDeclarationStringWriter alloc] init];
        subject = [[XMASObjcMethodDeclarationRewriter alloc] initWithMethodDeclarationStringWriter:methodDeclarationStringWriter];
    });

    describe(@"-changeMethodDeclaration:toNewMethod:", ^{
        __block XMASObjcMethodDeclaration *oldMethodDeclaration;
        __block XMASObjcMethodDeclaration *newMethodDeclaration;

        // FIXME :: break this out into a test helper
        NSString *pathToFixture = [[NSBundle mainBundle] pathForResource:@"RefactorMethodFixture" ofType:@"m"];
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
        NSString *temporaryFileName = [NSString stringWithFormat:@"RefactorMethod-%@.m", uuidStr];
        NSString *tempFixturePath = [NSTemporaryDirectory() stringByAppendingString:temporaryFileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager copyItemAtPath:pathToFixture toPath:tempFixturePath error:nil];

        beforeEach(^{
            NSArray *originalComponents = @[@"flashMessage"];
            NSArray *newComponents = @[@"flashMessage", @"withDelay"];

            NSArray *originalParams = @[[[XMASObjcMethodDeclarationParameter alloc] initWithType:@"NSString *" localName:@"message"]];
            NSArray *newParams = @[
                                   [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"NSString *" localName:@"message"],
                                   [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"NSNumber *" localName:@"delay"],
                                   ];

            oldMethodDeclaration = [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:originalComponents
                                                                                      parameters:originalParams
                                                                                      returnType:@"void"
                                                                                           range:NSMakeRange(60, 40)];

            newMethodDeclaration = [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:newComponents
                                                                                      parameters:newParams
                                                                                      returnType:@"BOOL"
                                                                                           range:NSMakeRange(60, 79)];
            [subject changeMethodDeclaration:oldMethodDeclaration
                                 toNewMethod:newMethodDeclaration
                                      inFile:tempFixturePath];
        });

        it(@"should change the method declaration to match the new method", ^{
            NSString *expectedFilePath = [[NSBundle mainBundle] pathForResource:@"RefactorMethodDeclarationExpected" ofType:@"m"];
            NSString *expectedFileContents = [NSString stringWithContentsOfFile:expectedFilePath
                                                                      encoding:NSUTF8StringEncoding
                                                                         error:nil];

            NSString *refactoredFileContents = [NSString stringWithContentsOfFile:tempFixturePath
                                                                         encoding:NSUTF8StringEncoding
                                                                            error:nil];
            refactoredFileContents should equal(expectedFileContents);
        });
    });
});

SPEC_END

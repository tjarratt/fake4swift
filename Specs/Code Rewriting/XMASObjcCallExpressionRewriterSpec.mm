#import <Cedar/Cedar.h>
#import "XMASObjcCallExpressionRewriter.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XMASObjcCallExpressionStringWriter.h"
#import "XMASObjcCallExpressionTokenFilter.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodCallParser.h"
#import "XMASAlert.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcCallExpressionRewriterSpec)

describe(@"XMASObjcCallExpressionRewriter", ^{
    __block XMASObjcCallExpressionRewriter *subject;

    __block XMASAlert *alerter;
    __block XMASObjcMethodCallParser *callExpressionParser;
    __block XMASObjcCallExpressionTokenFilter *callExpressionTokenFilter;
    __block XMASObjcCallExpressionStringWriter *callExpressionStringWriter;

    beforeEach(^{
        alerter = nice_fake_for([XMASAlert class]);
        callExpressionTokenFilter = [[XMASObjcCallExpressionTokenFilter alloc] init];
        callExpressionParser = [[XMASObjcMethodCallParser alloc] initWithCallExpressionTokenFilter:callExpressionTokenFilter];
        callExpressionStringWriter = [[XMASObjcCallExpressionStringWriter alloc] init];
        subject = [[XMASObjcCallExpressionRewriter alloc] initWithAlerter:alerter
                                                     callExpressionParser:callExpressionParser
                                               callExpressionStringWriter:callExpressionStringWriter];
    });

    describe(@"-changeCallsite:fromMethod:toNewMethod:", ^{
        __block XMASObjcMethodDeclaration *originalSelector;
        __block XMASObjcMethodDeclaration *newSelector;
        __block id callsite;

        NSString *pathToFixture = [[NSBundle mainBundle] pathForResource:@"RefactorMethodFixture" ofType:@"m"];

        CFUUIDRef uuid = CFUUIDCreate(NULL);
        CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
        NSString *temporaryFileName = [NSString stringWithFormat:@"RefactorMethodFixture-%@.m", uuidStr];

        NSString *tempFixturePath = [NSTemporaryDirectory() stringByAppendingString:temporaryFileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager copyItemAtPath:pathToFixture toPath:tempFixturePath error:nil];

        beforeEach(^{
            NSArray *originalComponents = @[@"initWithIcon", @"message", @"parentWindow", @"duration"];
            NSArray *originalParams = @[
                                        [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"id" localName:@"icon"],
                                        [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"message" localName:@"message"],
                                        [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"parentWindow" localName:@"window"],
                                        [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"duration" localName:@"duration"],
                                        ];
            originalSelector = [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:originalComponents
                                                                                  parameters:originalParams
                                                                                  returnType:@"void"
                                                                                       range:NSMakeRange(123, 244)];

            NSArray *newComponents = @[@"initWithIcon", @"message", @"parentWindow", @"duration", @"newArgument"];
            NSArray *newParams = @[
                                   [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"id" localName:@"icon"],
                                   [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"id" localName:@"message"],
                                   [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"id" localName:@"window"],
                                   [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"double" localName:@"duration"],
                                   [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"id" localName:@"newArgument"],
                                   ];
            newSelector = [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:newComponents
                                                                             parameters:newParams
                                                                             returnType:@"void"
                                                                                  range:NSMakeRange(0, 0)];
            callsite = nice_fake_for(@protocol(XMASXcode_IDEIndexSymbol));
            id fakeDVTFilePath = nice_fake_for(@protocol(XMASXcode_DVTFilePath));
            fakeDVTFilePath stub_method(@selector(pathString)).and_return(tempFixturePath);

            callsite stub_method(@selector(file)).and_return(fakeDVTFilePath);
            callsite stub_method(@selector(lineNumber)).and_return((NSUInteger)4);
            callsite stub_method(@selector(column)).and_return((NSUInteger)49);
        });

        it(@"should change the callsite to include the new parameters", ^{
            [subject changeCallsite:callsite fromMethod:originalSelector toNewMethod:newSelector];

            NSString *expectedFilePath = [[NSBundle mainBundle] pathForResource:@"RefactorMethodExpected" ofType:@"m"];
            NSString *updatedFileContents = [NSString stringWithContentsOfFile:expectedFilePath
                                                                      encoding:NSUTF8StringEncoding
                                                                         error:nil];

            NSString *refactoredFileContents = [NSString stringWithContentsOfFile:tempFixturePath
                                                                         encoding:NSUTF8StringEncoding
                                                                            error:nil];
            refactoredFileContents should equal(updatedFileContents);
        });
    });

    describe(@"when the method indicated cannot be found for whatever reason", ^{
        beforeEach(^{
            XMASObjcMethodDeclaration *unknownSelector = nice_fake_for([XMASObjcMethodDeclaration class]);
            unknownSelector stub_method(@selector(selectorString)).and_return(@"blurgle:withSpoo:andBruce:");
            id callsite = nice_fake_for(@protocol(XMASXcode_IDEIndexSymbol));
            id fakeDVTFilePath = nice_fake_for(@protocol(XMASXcode_DVTFilePath));
            fakeDVTFilePath stub_method(@selector(pathString)).and_return(@"/obv/fake/file.path");

            callsite stub_method(@selector(file)).and_return(fakeDVTFilePath);
            callsite stub_method(@selector(lineNumber)).and_return((NSUInteger)12);
            callsite stub_method(@selector(column)).and_return((NSUInteger)24);

            [subject changeCallsite:callsite fromMethod:unknownSelector toNewMethod:nil];
        });

        it(@"should show the user a sad alert", ^{
            NSString *expectedMessage = @"Aww shucks. Couldn't find 'blurgle:withSpoo:andBruce:' at line 12 column 24 in '/obv/fake/file.path'";
            alerter should have_received(@selector(flashMessage:withLogging:))
                .with(expectedMessage, YES);
        });
    });
});

SPEC_END
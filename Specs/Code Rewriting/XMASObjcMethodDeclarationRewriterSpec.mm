#import <Cedar/Cedar.h>
#import "XMASObjcMethodDeclarationRewriter.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XMASObjcMethodDeclarationStringWriter.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XcodeInterfaces.h"
#import "TempFileHelper.h"
#import "XMASAlert.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASObjcMethodDeclarationRewriterSpec)

describe(@"XMASObjcMethodDeclarationRewriter", ^{
    __block XMASObjcMethodDeclarationRewriter *subject;
    __block XMASAlert *alerter;
    __block XMASObjcMethodDeclarationParser *methodDeclarationParser;
    __block XMASObjcMethodDeclarationStringWriter *methodDeclarationStringWriter;

    beforeEach(^{
        alerter = nice_fake_for([XMASAlert class]);
        methodDeclarationParser = [[XMASObjcMethodDeclarationParser alloc] init];
        methodDeclarationStringWriter = [[XMASObjcMethodDeclarationStringWriter alloc] init];
        subject = [[XMASObjcMethodDeclarationRewriter alloc] initWithMethodDeclarationStringWriter:methodDeclarationStringWriter
                                                                           methodDeclarationParser:methodDeclarationParser
                                                                                           alerter:alerter];
    });

    describe(@"-changeMethodDeclaration:toNewMethod:", ^{
        __block XMASObjcMethodDeclaration *oldMethodDeclaration;
        __block XMASObjcMethodDeclaration *newMethodDeclaration;

        NSString *tempFixturePath = [TempFileHelper temporaryFilePathForFixture:@"RefactorMethodFixture" ofType:@"m"];

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
                                                                                           range:NSMakeRange(60, 40)
                                                                                      lineNumber:3
                                                                                    columnNumber:1];

            newMethodDeclaration = [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:newComponents
                                                                                      parameters:newParams
                                                                                      returnType:@"BOOL"
                                                                                           range:NSMakeRange(60, 79)
                                                                                      lineNumber:3
                                                                                    columnNumber:1];
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

    describe(@"changeMethodDeclarationForSymbol:toMethod:", ^{

        context(@"when the method specified can be found in the file provided", ^{
            NSString *tempFixturePath = [TempFileHelper temporaryFilePathForFixture:@"RefactorMethodFixture" ofType:@"h"];

            beforeEach(^{
                XC(DVTFilePath) fakeDVTFilePath = nice_fake_for(@protocol(XCP(DVTFilePath)));
                fakeDVTFilePath stub_method(@selector(pathString)).and_return(tempFixturePath);

                XC(IDEIndexSymbol) symbol = nice_fake_for(@protocol(XCP(IDEIndexSymbol)));
                symbol stub_method(@selector(file)).and_return(fakeDVTFilePath);
                symbol stub_method(@selector(lineNumber)).and_return((NSUInteger)3);
                symbol stub_method(@selector(column)).and_return((NSUInteger)1);

                NSArray *selectorComponents = @[@"flashMessage", @"duration"];
                NSArray *parameters = @[
                                        [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"NSString *" localName:@"message"],
                                        [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"NSNumber *" localName:@"duration"],
                                        ];
                XMASObjcMethodDeclaration *newMethodDeclaration = [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:selectorComponents
                                                                                                                     parameters:parameters
                                                                                                                     returnType:@"void"
                                                                                                                          range:NSMakeRange(0, 0)
                                                                                                                     lineNumber:3
                                                                                                                   columnNumber:1];

                [subject changeMethodDeclarationForSymbol:symbol toMethod:newMethodDeclaration];
            });

            it(@"should change the method declaration to match the new method", ^{
                NSString *expectedFilePath = [[NSBundle mainBundle] pathForResource:@"RefactorMethodExpected" ofType:@"h"];
                NSString *expectedFileContents = [NSString stringWithContentsOfFile:expectedFilePath
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:nil];

                NSString *refactoredFileContents = [NSString stringWithContentsOfFile:tempFixturePath
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
                refactoredFileContents should equal(expectedFileContents);
            });
        });

        context(@"when the method cannot be found", ^{
            beforeEach(^{
                XC(DVTFilePath) fakeDVTFilePath = nice_fake_for(@protocol(XCP(DVTFilePath)));
                fakeDVTFilePath stub_method(@selector(pathString)).and_return(@"/some/obviously/fake_file.m");

                XC(IDEIndexSymbol) unknownSymbol = nice_fake_for(@protocol(XCP(IDEIndexSymbol)));
                unknownSymbol stub_method(@selector(file)).and_return(fakeDVTFilePath);
                unknownSymbol stub_method(@selector(lineNumber)).and_return((NSUInteger)55);
                unknownSymbol stub_method(@selector(column)).and_return((NSUInteger)222);

                XMASObjcMethodDeclaration *unknownMethodDeclaration = nice_fake_for([XMASObjcMethodDeclaration class]);
                unknownMethodDeclaration stub_method(@selector(selectorString))
                    .and_return(@"thisMethod:does:not:exist:");

                [subject changeMethodDeclarationForSymbol:unknownSymbol toMethod:unknownMethodDeclaration];
            });

            it(@"should alert the user", ^{
                alerter should have_received(@selector(flashMessage:))
                    .with(@"Aww shucks. Couldn't find 'thisMethod:does:not:exist:' in 'fake_file.m' at line 55 column 222");
            });
        });
    });
});

SPEC_END

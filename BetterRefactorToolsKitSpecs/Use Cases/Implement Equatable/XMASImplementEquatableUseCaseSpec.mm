#import <Cedar/Cedar.h>

#import "BetterRefactorToolsKitSpecs-Swift.h"
#import "BetterRefactorToolsKitModule.h"
#import "XMASAlerter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASImplementEquatableUseCaseSpec)

describe(@"XMASImplementEquatableUseCase", ^{
    __block XMASImplementEquatableUseCase *subject;

    __block XMASLogger *logger;
    __block id<XMASAlerter> alerter;
    __block XMASEquatableWriter *equatableWriter;
    __block id<XMASSelectedSourceFileOracle> selectedFileOracle;
    __block XMASParseSelectedStructWorkflow *parseStructWorkflow;

    StructDeclaration *selectedStruct = [[StructDeclaration alloc] initWithName:@"MyStruct"
                                                                       filePath:@"some/fake/path"
                                                                         fields:@[@"bigtime"]];

    beforeEach(^{
        logger = nice_fake_for([XMASLogger class]);
        alerter = nice_fake_for(@protocol(XMASAlerter));
        equatableWriter = nice_fake_for([XMASEquatableWriter class]);
        selectedFileOracle = nice_fake_for(@protocol(XMASSelectedSourceFileOracle));
        parseStructWorkflow = nice_fake_for([XMASParseSelectedStructWorkflow class]);

        subject = [[XMASImplementEquatableUseCase alloc] initWithLogger:logger
                                                                alerter:alerter
                                                        equatableWriter:equatableWriter
                                                     selectedFileOracle:selectedFileOracle
                                                    parseStructWorkflow:parseStructWorkflow];
    });

    subjectAction(^{
        [subject safelyAddEquatableToSelectedStruct];
    });

    describe(@"when a swift struct is selected", ^{
        beforeEach(^{
            selectedFileOracle stub_method(@selector(selectedFilePath))
                .and_return(@"/cool/stuff.swift");

            parseStructWorkflow stub_method(@selector(selectedStructInFile:error:))
                .and_return(selectedStruct);
        });

        it(@"should ask its workflow to parse the selected struct from the open file", ^{
            parseStructWorkflow should have_received(@selector(selectedStructInFile:error:))
                .with(@"/cool/stuff.swift", Arguments::anything);
        });

        it(@"should ask its equatable writer to rewrite the source file", ^{
            equatableWriter should have_received(@selector(addEquatableImplForStruct:error:))
                .with(selectedStruct, Arguments::anything);
        });

        context(@"when an error is thrown while writing the equatable impl", ^{
            NSError *expectedError = [NSError errorWithDomain:@"whoops-all-crunch-berries"
                                                         code:333
                                                     userInfo:nil];

            beforeEach(^{
                equatableWriter stub_method(@selector(addEquatableImplForStruct:error:))
                    .and_do_block(^BOOL(StructDeclaration *decl, NSError **error) {
                        *error = expectedError;
                        return NO;
                    });
            });

            it(@"should alert the user that the action failed", ^{
                alerter should have_received(@selector(flashComfortingMessageForError:))
                    .with(expectedError);
            });
        });

        context(@"when writing the equatable impl completes successfully", ^{
            beforeEach(^{
                equatableWriter stub_method(@selector(addEquatableImplForStruct:error:))
                    .and_return(YES);
            });

            it(@"should tell the user the action completed", ^{
                alerter should have_received(@selector(flashMessage:withImage:shouldLogMessage:))
                    .with(@"Success!", XMASAlertImageImplementEquatable, NO);
            });
        });
    });

    describe(@"when no struct is selected", ^{
        beforeEach(^{
            parseStructWorkflow stub_method(@selector(selectedStructInFile:error:))
                .and_return(nil);
        });

        it(@"should alert the user that the action failed", ^{
            alerter should have_received(@selector(flashMessage:withImage:shouldLogMessage:))
                .with(@"Select a Swift struct", XMASAlertImageNoSwiftFileSelected, NO);
        });
    });

    describe(@"when an error is thrown determining what struct is selected", ^{
        NSError *expectedError = [NSError errorWithDomain:@"aww-shucks"
                                                     code:666
                                                 userInfo:nil];
        beforeEach(^{
            parseStructWorkflow stub_method(@selector(selectedStructInFile:error:))
                .and_do_block(^NSString *(NSString *filePath, NSError **error) {
                    *error = expectedError;
                    return nil;
                });
        });

        it(@"should alert the user the action failed", ^{
            alerter should have_received(@selector(flashComfortingMessageForError:))
                .with(expectedError);
        });
    });

    describe(@"when a swift file is not selected", ^{
        beforeEach(^{
            selectedFileOracle stub_method(@selector(selectedFilePath))
                .and_return(@"/whoops/i/accidentally/all/the/ping/pong/balls.m");
        });

        it(@"should tell the user to select a swift file", ^{
            alerter should have_received(@selector(flashMessage:withImage:shouldLogMessage:))
                .with(@"Select a Swift struct", XMASAlertImageNoSwiftFileSelected, NO);
        });
    });
});

SPEC_END

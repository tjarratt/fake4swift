#import <Cedar/Cedar.h>
#import <BetterRefactorToolsKit/BetterRefactorToolsKit.h>

#import "XMASGenerateFakeForSwiftProtocolUseCase.h"
#import "BetterRefactorToolsKitSpecs-Swift.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASGenerateFakeForSwiftProtocolUseCaseSpec)

describe(@"XMASGenerateFakeForSwiftProtocolUseCase", ^{
    __block XMASGenerateFakeForSwiftProtocolUseCase *subject;

    __block id<XMASAlerter> alerter;
    __block XMASLogger *logger;
    __block XMASFakeProtocolPersister *fakeProtocolPersister;
    __block id<XMASSelectedSourceFileOracle> selectedSourceFileOracle;
    __block XMASParseSelectedProtocolWorkFlow *parseProtocolWorkFlow;

    beforeEach(^{
        alerter = nice_fake_for(@protocol(XMASAlerter));
        logger = nice_fake_for([XMASLogger class]);
        parseProtocolWorkFlow = nice_fake_for([XMASParseSelectedProtocolWorkFlow class]);
        fakeProtocolPersister = nice_fake_for([XMASFakeProtocolPersister class]);
        selectedSourceFileOracle = nice_fake_for(@protocol(XMASSelectedSourceFileOracle));

        subject = [[XMASGenerateFakeForSwiftProtocolUseCase alloc] initWithAlerter:alerter
                                                                            logger:logger
                                                     parseSelectedProtocolWorkFlow:parseProtocolWorkFlow
                                                             fakeProtocolPersister:fakeProtocolPersister
                                                          selectedSourceFileOracle:selectedSourceFileOracle];
    });

    subjectAction(^{
        [subject safelyGenerateFakeForSelectedProtocol];
    });

    describe(@"when the cursor is inside a swift protocol declaration", ^{
        __block ProtocolDeclaration *fakeProtocol;
        beforeEach(^{
            fakeProtocol = nice_fake_for([ProtocolDeclaration class]);
            fakeProtocol stub_method(@selector(name)).and_return(@"MySpecialProtocol");

            parseProtocolWorkFlow stub_method(@selector(selectedProtocolInFile:error:))
                .with(@"/path/to/something.swift", Arguments::anything)
                .and_return(fakeProtocol);

            selectedSourceFileOracle stub_method(@selector(selectedFilePath))
                .and_return(@"/path/to/something.swift");
        });

        context(@"and the fake can be persisted to disk", ^{
            it(@"should write out a new file using its fakeProtocolPersister", ^{
                fakeProtocolPersister should have_received(@selector(persistFakeForProtocol:nearSourceFile:error:))
                    .with(fakeProtocol)
                    .and_with(@"/path/to/something.swift")
                    .and_with(Arguments::anything);
            });

            it(@"should alert the user the action succeeded", ^{
                alerter should have_received(@selector(flashMessage:withImage:shouldLogMessage:))
                    .with(@"Success!",
                          XMASAlertImageGeneratedFake,
                          NO);
            });
        });

        context(@"but an error occurs persisting the fake", ^{
            beforeEach(^{
                fakeProtocolPersister stub_method(@selector(persistFakeForProtocol:nearSourceFile:error:))
                    .and_do_block(^BOOL(ProtocolDeclaration *protocolDecl, NSString *file, NSError **error) {
                        *error = [NSError errorWithDomain:@"SpecsDomain" code:12 userInfo:nil];
                        return NO;
                    });
            });

            it(@"should not alert the user that it generated the fake", ^{
                alerter should_not have_received(@selector(flashMessage:withImage:shouldLogMessage:))
                    .with(@"Success!", Arguments::anything, Arguments::anything);
            });

            it(@"should alert the user that something went wrong", ^{
                alerter should have_received(@selector(flashComfortingMessageForError:));
            });
        });

        context(@"but the protocol to stub includes additional protocols", ^{
            beforeEach(^{
                ProtocolDeclaration *unsupportedProtocolDecl = [[ProtocolDeclaration alloc] initWithName:@"UnsupportedProtocol"
                                                                                          containingFile:@"/some/fake/path.swift"
                                                                                             rangeInFile:NSMakeRange(0, 0)
                                                                                           usesTypealias:NO
                                                                                       includedProtocols:@[@"This", @"Isn't", @"Supported"]
                                                                                         instanceMethods:@[]
                                                                                           staticMethods:@[]
                                                                                         mutatingMethods:@[]
                                                                                            initializers:@[]
                                                                                                 getters:@[]
                                                                                                 setters:@[]
                                                                                           staticGetters:@[]
                                                                                           staticSetters:@[]
                                                                                        subscriptGetters:@[]
                                                                                        subscriptSetters:@[]];

                parseProtocolWorkFlow stub_method(@selector(selectedProtocolInFile:error:))
                    .again()
                    .with(@"/path/to/something.swift", Arguments::anything)
                    .and_return(unsupportedProtocolDecl);
            });

            it(@"should alert the user this can't be generated", ^{
                alerter should have_received(@selector(flashMessage:withImage:shouldLogMessage:))
                    .with(@"Check Console.app", XMASAlertImageAbjectFailure, NO);
            });

            it(@"should not attempt to persist any files", ^{
                fakeProtocolPersister should_not have_received(@selector(persistFakeForProtocol:nearSourceFile:error:));
            });

            it(@"should log a more detailed message", ^{
                logger should have_received(@selector(logMessage:))
                    .with(@"Unable to generate fake 'UnsupportedProtocol'. It includes 3 other protocols -- this is not supported yet. Sorry!");
            });
        });

        context(@"but the protocol to stub uses typealias", ^{
            beforeEach(^{
                ProtocolDeclaration *unsupportedProtocolDecl = [[ProtocolDeclaration alloc] initWithName:@"UnsupportedProtocol"
                                                                                          containingFile:@"/some/fake/path.swift"
                                                                                             rangeInFile:NSMakeRange(0, 0)
                                                                                           usesTypealias:YES
                                                                                       includedProtocols:@[]
                                                                                         instanceMethods:@[]
                                                                                           staticMethods:@[]
                                                                                         mutatingMethods:@[]
                                                                                            initializers:@[]
                                                                                                 getters:@[]
                                                                                                 setters:@[]
                                                                                           staticGetters:@[]
                                                                                           staticSetters:@[]
                                                                                        subscriptGetters:@[]
                                                                                        subscriptSetters:@[]];

                parseProtocolWorkFlow stub_method(@selector(selectedProtocolInFile:error:))
                    .again()
                    .with(@"/path/to/something.swift", Arguments::anything)
                    .and_return(unsupportedProtocolDecl);
            });

            it(@"should alert the user this can't be generated", ^{
                alerter should have_received(@selector(flashMessage:withImage:shouldLogMessage:))
                    .with(@"Check Console.app", XMASAlertImageAbjectFailure, NO);
            });

            it(@"should not attempt to persist any files", ^{
                fakeProtocolPersister should_not have_received(@selector(persistFakeForProtocol:nearSourceFile:error:));
            });

            it(@"should log a more detailed message", ^{
                logger should have_received(@selector(logMessage:))
                    .with(@"Unable to generate fake 'UnsupportedProtocol'. It uses a typealias -- this is not supported yet. Sorry!");
            });
        });
    });

    describe(@"when the file is not a swift file", ^{
        beforeEach(^{
            selectedSourceFileOracle stub_method(@selector(selectedFilePath))
                .and_return(@"/path/to/whoops.my_bad");
        });

        it(@"should alert the user this only works with swift", ^{
            alerter should have_received(@selector(flashMessage:withImage:shouldLogMessage:))
                .with(@"Select a Swift protocol", XMASAlertImageNoSwiftFileSelected, NO);
        });
    });

    describe(@"when determining the selected protocol throws an error", ^{
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: @"ruh roh"};
        NSError *expectedError = [[NSError alloc] initWithDomain:@"some-domain"
                                                            code:1
                                                        userInfo:userInfo];
        beforeEach(^{
            selectedSourceFileOracle stub_method(@selector(selectedFilePath))
                .and_return(@"/path/to/something.swift");
            parseProtocolWorkFlow stub_method(@selector(selectedProtocolInFile:error:))
                .and_do_block(^NSString *(id something, NSError **error) {
                    *error = expectedError;
                    return nil;
                });
        });

        it(@"should show the user the error message", ^{
            alerter should have_received(@selector(flashComfortingMessageForError:))
                .with(expectedError);
        });
    });
});

SPEC_END

#import <Cedar/Cedar.h>
#import <BetterRefactorToolsKit/BetterRefactorToolsKit.h>
#import <BetterRefactorToolsKit/BetterRefactorToolsKit-Swift.h>

#import "GenerateFakeForSwiftProtocolUseCase.h"
#import "PluginSpecs-Swift.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(GenerateFakeForSwiftProtocolUseCaseSpec)

describe(@"GenerateFakeForSwiftProtocolUseCase", ^{
    __block GenerateFakeForSwiftProtocolUseCase *subject;

    __block id<XMASAlerter> alerter;
    __block XMASLogger *logger;
    __block XMASFakeProtocolPersister *fakeProtocolPersister;
    __block id<XMASSelectedSourceFileOracle> selectedSourceFileOracle;
    __block XMASParseSelectedProtocolWorkFlow *parseProtocolUseCase;

    beforeEach(^{
        alerter = nice_fake_for(@protocol(XMASAlerter));
        logger = nice_fake_for([XMASLogger class]);
        parseProtocolUseCase = nice_fake_for([XMASParseSelectedProtocolWorkFlow class]);
        fakeProtocolPersister = nice_fake_for([XMASFakeProtocolPersister class]);
        selectedSourceFileOracle = nice_fake_for(@protocol(XMASSelectedSourceFileOracle));

        subject = [[GenerateFakeForSwiftProtocolUseCase alloc] initWithAlerter:alerter
                                                           logger:logger
                                                selectedTextProxy:parseProtocolUseCase
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

            parseProtocolUseCase stub_method(@selector(selectedProtocolInFile:error:))
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
                alerter should have_received(@selector(flashMessage:))
                    .with(@"Generated FakeMySpecialProtocol successfully!");
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
                alerter should_not have_received(@selector(flashMessage:))
                    .with(@"Generated FakeMySpecialProtocol successfully!");
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

                parseProtocolUseCase stub_method(@selector(selectedProtocolInFile:error:))
                    .again()
                    .with(@"/path/to/something.swift", Arguments::anything)
                    .and_return(unsupportedProtocolDecl);
            });

            it(@"should alert the user this can't be generated", ^{
                alerter should have_received(@selector(flashMessage:))
                    .with(@"FAILED. Check Console.app");
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

                parseProtocolUseCase stub_method(@selector(selectedProtocolInFile:error:))
                    .again()
                    .with(@"/path/to/something.swift", Arguments::anything)
                    .and_return(unsupportedProtocolDecl);
            });

            it(@"should alert the user this can't be generated", ^{
                alerter should have_received(@selector(flashMessage:))
                    .with(@"FAILED. Check Console.app");
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
            alerter should have_received(@selector(flashMessage:))
                .with(@"generate-fake only works with Swift source files");
        });
    });

    describe(@"when the cursor is not inside a protocol declaration", ^{
        beforeEach(^{
            selectedSourceFileOracle stub_method(@selector(selectedFilePath))
                .and_return(@"/path/to/something.swift");
            parseProtocolUseCase stub_method(@selector(selectedProtocolInFile:error:))
                .and_do_block(^NSString *(id something, NSError **error) {
                    *error = [[NSError alloc] initWithDomain:@"some-domain" code:1 userInfo:nil];
                    return nil;
                });
        });

        it(@"should alert the user to select a protocol", ^{
            alerter should have_received(@selector(flashMessage:))
                .with(@"put your cursor in a protocol declaration to generate a fake for it");
        });
    });
});

SPEC_END

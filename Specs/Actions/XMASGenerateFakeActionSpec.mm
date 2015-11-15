#import <Cedar/Cedar.h>
#import "Specs-Swift.h"

#import "XMASAlert.h"
#import "XMASSelectedTextProxy.h"
#import "XMASGenerateFakeAction.h"
#import "XMASFakeProtocolPersister.h"
#import "XMASCurrentSourceCodeDocumentProxy.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASGenerateFakeActionSpec)

describe(@"XMASGenerateFakeAction", ^{
    __block XMASGenerateFakeAction *subject;

    __block XMASAlert *alerter;
    __block XMASLogger *logger;
    __block id<XMASSelectedTextProxy> selectedTextProxy;
    __block XMASFakeProtocolPersister *fakeProtocolPersister;
    __block XMASCurrentSourceCodeDocumentProxy *sourceCodeDocumentProxy;

    beforeEach(^{
        alerter = nice_fake_for([XMASAlert class]);
        logger = nice_fake_for([XMASLogger class]);
        selectedTextProxy = nice_fake_for(@protocol(XMASSelectedTextProxy));
        fakeProtocolPersister = nice_fake_for([XMASFakeProtocolPersister class]);
        sourceCodeDocumentProxy = nice_fake_for([XMASCurrentSourceCodeDocumentProxy class]);

        subject = [[XMASGenerateFakeAction alloc] initWithAlerter:alerter
                                                           logger:logger
                                                selectedTextProxy:selectedTextProxy
                                            fakeProtocolPersister:fakeProtocolPersister
                                          sourceCodeDocumentProxy:sourceCodeDocumentProxy];
    });

    subjectAction(^{
        [subject safelyGenerateFakeForProtocolUnderCursor];
    });

    describe(@"when the cursor is inside a swift protocol declaration", ^{
        __block ProtocolDeclaration *fakeProtocol;
        beforeEach(^{
            fakeProtocol = nice_fake_for([ProtocolDeclaration class]);
            fakeProtocol stub_method(@selector(name)).and_return(@"MySpecialProtocol");

            selectedTextProxy stub_method(@selector(selectedProtocolInFile:))
                .with(@"/path/to/something.swift")
                .and_return(fakeProtocol);

            sourceCodeDocumentProxy stub_method(@selector(currentSourceCodeFilePath))
                .and_return(@"/path/to/something.swift");
        });

        context(@"and the fake can be persisted to disk", ^{
            it(@"should write out a new file using its fakeProtocolPersister", ^{
                fakeProtocolPersister should have_received(@selector(persistFakeForProtocol:nearSourceFile:))
                    .with(fakeProtocol)
                    .and_with(@"/path/to/something.swift");
            });

            it(@"should alert the user the action succeeded", ^{
                alerter should have_received(@selector(flashMessage:))
                    .with(@"Generated FakeMySpecialProtocol successfully!");
            });
        });

        context(@"but an error occurs persisting the fake", ^{
            beforeEach(^{
                fakeProtocolPersister stub_method(@selector(persistFakeForProtocol:nearSourceFile:))
                    .and_raise_exception();
            });

            it(@"should not alert the user that it generated the fake", ^{
                alerter should_not have_received(@selector(flashMessage:))
                    .with(@"Generated FakeMySpecialProtocol successfully!");
            });

            it(@"should alert the user that something went wrong", ^{
                alerter should have_received(@selector(flashComfortingMessageForException:));
            });
        });

        context(@"but the protocol to stub includes additional protocols", ^{
            beforeEach(^{
                ProtocolDeclaration *unsupportedProtocolDecl = [[ProtocolDeclaration alloc] initWithName:@"UnsupportedProtocol"
                                                                                           usesTypeAlias:NO
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

                selectedTextProxy stub_method(@selector(selectedProtocolInFile:))
                    .again()
                    .with(@"/path/to/something.swift")
                    .and_return(unsupportedProtocolDecl);
            });

            it(@"should alert the user this can't be generated", ^{
                alerter should have_received(@selector(flashMessage:))
                    .with(@"FAILED. Check Console.app");
            });

            it(@"should not attempt to persist any files", ^{
                fakeProtocolPersister should_not have_received(@selector(persistFakeForProtocol:nearSourceFile:));
            });

            it(@"should log a more detailed message", ^{
                logger should have_received(@selector(logMessage:))
                    .with(@"Unable to generate fake 'UnsupportedProtocol'. It includes 3 other protocols -- this is not supported yet. Sorry!");
            });
        });

        context(@"but the protocol to stub uses typealias", ^{
            beforeEach(^{
                ProtocolDeclaration *unsupportedProtocolDecl = [[ProtocolDeclaration alloc] initWithName:@"UnsupportedProtocol"
                                                                                           usesTypeAlias:YES
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

                selectedTextProxy stub_method(@selector(selectedProtocolInFile:))
                    .again()
                    .with(@"/path/to/something.swift")
                    .and_return(unsupportedProtocolDecl);
            });

            it(@"should alert the user this can't be generated", ^{
                alerter should have_received(@selector(flashMessage:))
                    .with(@"FAILED. Check Console.app");
            });

            it(@"should not attempt to persist any files", ^{
                fakeProtocolPersister should_not have_received(@selector(persistFakeForProtocol:nearSourceFile:));
            });

            it(@"should log a more detailed message", ^{
                logger should have_received(@selector(logMessage:))
                    .with(@"Unable to generate fake 'UnsupportedProtocol'. It uses a typealias -- this is not supported yet. Sorry!");
            });
        });
    });

    describe(@"when the file is not a swift file", ^{
        beforeEach(^{
            sourceCodeDocumentProxy stub_method(@selector(currentSourceCodeFilePath))
                .and_return(@"/path/to/whoops.my_bad");
        });

        it(@"should alert the user this only works with swift", ^{
            alerter should have_received(@selector(flashMessage:))
                .with(@"generate-fake only works with Swift source files");
        });
    });

    describe(@"when the cursor is not inside a protocol declaration", ^{
        beforeEach(^{
            sourceCodeDocumentProxy stub_method(@selector(currentSourceCodeFilePath))
                .and_return(@"/path/to/something.swift");
        });

        it(@"should alert the user to select a protocol", ^{
            alerter should have_received(@selector(flashMessage:))
                .with(@"put your cursor on a swift protocol to generate a fake for it");
        });
    });
});

SPEC_END

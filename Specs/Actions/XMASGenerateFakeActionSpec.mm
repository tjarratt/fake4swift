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
    __block id<XMASSelectedTextProxy> selectedTextProxy;
    __block XMASFakeProtocolPersister *fakeProtocolPersister;
    __block XMASCurrentSourceCodeDocumentProxy *sourceCodeDocumentProxy;

    beforeEach(^{
        alerter = nice_fake_for([XMASAlert class]);
        selectedTextProxy = nice_fake_for(@protocol(XMASSelectedTextProxy));
        fakeProtocolPersister = nice_fake_for([XMASFakeProtocolPersister class]);
        sourceCodeDocumentProxy = nice_fake_for([XMASCurrentSourceCodeDocumentProxy class]);

        subject = [[XMASGenerateFakeAction alloc] initWithAlerter:alerter
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

        it(@"should write out a new file using its fakeProtocolPersister", ^{
            fakeProtocolPersister should have_received(@selector(persistFakeForProtocol:nearSourceFile:))
                .with(fakeProtocol)
                .and_with(@"/path/to/something.swift");
        });

        it(@"should alert the user the action succeeded", ^{
            alerter should have_received(@selector(flashMessage:))
                .with(@"generating fake 'MySpecialProtocol'");
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

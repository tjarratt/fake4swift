#import <Cedar/Cedar.h>
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASChangeMethodSignatureController.h"
#import "XMASWindowProvider.h"
#import "XMASAlert.h"
#import "XMASIndexedSymbolRepository.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASChangeMethodSignatureControllerProviderSpec)

describe(@"XMASChangeMethodSignatureControllerProvider", ^{
    __block XMASChangeMethodSignatureControllerProvider *subject;
    __block XMASIndexedSymbolRepository *indexedSymbolRepository;
    __block XMASWindowProvider *windowProvider;
    __block XMASAlert *alerter;

    beforeEach(^{
        alerter = nice_fake_for(alerter);
        windowProvider = nice_fake_for([XMASWindowProvider class]);
        indexedSymbolRepository = nice_fake_for([XMASIndexedSymbolRepository class]);

        subject = [[XMASChangeMethodSignatureControllerProvider alloc] initWithWindowProvider:windowProvider
                                                                                      alerter:alerter
                                                                      indexedSymbolRepository:indexedSymbolRepository];
    });

    describe(@"-provideInstance", ^{
        __block XMASChangeMethodSignatureController *controller;
        __block id<XMASChangeMethodSignatureControllerDelegate> delegate;

        beforeEach(^{
            delegate = nice_fake_for(@protocol(XMASChangeMethodSignatureControllerDelegate));
            controller = [subject provideInstanceWithDelegate:delegate];
        });

        it(@"should provide a change method signature controller", ^{
            controller should be_instance_of([XMASChangeMethodSignatureController class]);
        });

        it(@"should pass its delegate to the controller", ^{
            controller.delegate should be_same_instance_as(delegate);
        });

        it(@"should pass an NSWindow provider to its controller", ^{
            controller.windowProvider should be_same_instance_as(windowProvider);
        });

        it(@"should have an alert-presenter", ^{
            controller.alerter should be_same_instance_as(alerter);
        });

        it(@"should have an indexedSymbolRepository", ^{
            controller.indexedSymbolRepository should be_same_instance_as(indexedSymbolRepository);
        });
    });
});

SPEC_END

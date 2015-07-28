#import <Cedar/Cedar.h>
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASChangeMethodSignatureController.h"
#import "XMASWindowProvider.h"
#import "XMASAlert.h"
#import "XMASIndexedSymbolRepository.h"
#import "XMASObjcCallExpressionRewriter.h"
#import "XMASObjcMethodDeclarationRewriter.h"
#import "XMASObjcMethodDeclarationStringWriter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(XMASChangeMethodSignatureControllerProviderSpec)

describe(@"XMASChangeMethodSignatureControllerProvider", ^{
    __block XMASChangeMethodSignatureControllerProvider *subject;

    __block XMASObjcMethodDeclarationStringWriter *methodDeclarationStringWriter;
    __block XMASObjcMethodDeclarationRewriter *methodDeclarationRewriter;
    __block XMASObjcCallExpressionRewriter *callExpressionRewriter;
    __block XMASIndexedSymbolRepository *indexedSymbolRepository;
    __block XMASWindowProvider *windowProvider;
    __block XMASAlert *alerter;

    beforeEach(^{
        alerter = nice_fake_for(alerter);
        windowProvider = nice_fake_for([XMASWindowProvider class]);
        indexedSymbolRepository = nice_fake_for([XMASIndexedSymbolRepository class]);
        callExpressionRewriter = nice_fake_for([XMASObjcCallExpressionRewriter class]);
        methodDeclarationRewriter = nice_fake_for([XMASObjcMethodDeclarationRewriter class]);
        methodDeclarationStringWriter = nice_fake_for([XMASObjcMethodDeclarationStringWriter class]);

        subject = [[XMASChangeMethodSignatureControllerProvider alloc] initWithWindowProvider:windowProvider
                                                                                      alerter:alerter
                                                                      indexedSymbolRepository:indexedSymbolRepository
                                                                       callExpressionRewriter:callExpressionRewriter
                                                                methodDeclarationStringWriter:methodDeclarationStringWriter
                                                                    methodDeclarationRewriter:methodDeclarationRewriter];
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

        it(@"should have a call expression rewriter", ^{
            controller.callExpressionRewriter should be_same_instance_as(callExpressionRewriter);
        });

        it(@"should have a call expression string writer", ^{
            controller.methodDeclarationStringWriter should be_same_instance_as(methodDeclarationStringWriter);
        });

        it(@"should have a method declaration rewriter", ^{
            controller.methodDeclarationRewriter should be_same_instance_as(methodDeclarationRewriter);
        });
    });
});

SPEC_END

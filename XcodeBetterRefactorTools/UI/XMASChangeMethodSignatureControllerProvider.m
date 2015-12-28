#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASChangeMethodSignatureController.h"
#import "XMASWindowProvider.h"
#import "XMASMethodOccurrencesRepository.h"
#import "XMASObjcCallExpressionRewriter.h"
#import "XMASObjcMethodDeclarationRewriter.h"
#import "XMASObjcMethodDeclarationStringWriter.h"

@interface XMASChangeMethodSignatureControllerProvider ()
@property (nonatomic) id<XMASAlerter> alerter;
@property (nonatomic) XMASWindowProvider *windowProvider;
@property (nonatomic) XMASMethodOccurrencesRepository *methodOccurrencesRepository;
@property (nonatomic) XMASObjcCallExpressionRewriter *callExpressionRewriter;
@property (nonatomic) XMASObjcMethodDeclarationRewriter *methodDeclarationRewriter;
@property (nonatomic) XMASObjcMethodDeclarationStringWriter *methodDeclarationStringWriter;
@end

@implementation XMASChangeMethodSignatureControllerProvider

- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider
                               alerter:(id<XMASAlerter>)alerter
               methodOccurrencesRepository:(XMASMethodOccurrencesRepository *)methodOccurrencesRepository
                callExpressionRewriter:(XMASObjcCallExpressionRewriter *)callExpressionRewriter
         methodDeclarationStringWriter:(XMASObjcMethodDeclarationStringWriter *)methodDeclarationStringWriter
             methodDeclarationRewriter:(XMASObjcMethodDeclarationRewriter *)methodDeclarationRewriter {
    if (self = [super init]) {
        self.alerter = alerter;
        self.windowProvider = windowProvider;
        self.methodOccurrencesRepository = methodOccurrencesRepository;
        self.callExpressionRewriter = callExpressionRewriter;
        self.methodDeclarationRewriter = methodDeclarationRewriter;
        self.methodDeclarationStringWriter = methodDeclarationStringWriter;
    }

    return self;
}

- (XMASChangeMethodSignatureController *)provideInstanceWithDelegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate {
    return [[XMASChangeMethodSignatureController alloc] initWithWindowProvider:self.windowProvider
                                                                      delegate:delegate
                                                                       alerter:self.alerter
                                                       methodOccurrencesRepository:self.methodOccurrencesRepository
                                                        callExpressionRewriter:self.callExpressionRewriter
                                                 methodDeclarationStringWriter:self.methodDeclarationStringWriter
                                                     methodDeclarationRewriter:self.methodDeclarationRewriter];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

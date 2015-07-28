#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASChangeMethodSignatureController.h"
#import "XMASWindowProvider.h"
#import "XMASIndexedSymbolRepository.h"
#import "XMASObjcCallExpressionRewriter.h"
#import "XMASObjcMethodDeclarationRewriter.h"
#import "XMASObjcMethodDeclarationStringWriter.h"

@interface XMASChangeMethodSignatureControllerProvider ()
@property (nonatomic) XMASAlert *alerter;
@property (nonatomic) XMASWindowProvider *windowProvider;
@property (nonatomic) XMASIndexedSymbolRepository *indexedSymbolRepository;
@property (nonatomic) XMASObjcCallExpressionRewriter *callExpressionRewriter;
@property (nonatomic) XMASObjcMethodDeclarationRewriter *methodDeclarationRewriter;
@property (nonatomic) XMASObjcMethodDeclarationStringWriter *methodDeclarationStringWriter;
@end

@implementation XMASChangeMethodSignatureControllerProvider

- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider
                               alerter:(XMASAlert *)alerter
               indexedSymbolRepository:(XMASIndexedSymbolRepository *)indexedSymbolRepository
                callExpressionRewriter:(XMASObjcCallExpressionRewriter *)callExpressionRewriter
         methodDeclarationStringWriter:(XMASObjcMethodDeclarationStringWriter *)methodDeclarationStringWriter
             methodDeclarationRewriter:(XMASObjcMethodDeclarationRewriter *)methodDeclarationRewriter {
    if (self = [super init]) {
        self.alerter = alerter;
        self.windowProvider = windowProvider;
        self.indexedSymbolRepository = indexedSymbolRepository;
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
                                                       indexedSymbolRepository:self.indexedSymbolRepository
                                                        callExpressionRewriter:self.callExpressionRewriter
                                                 methodDeclarationStringWriter:self.methodDeclarationStringWriter
                                                     methodDeclarationRewriter:self.methodDeclarationRewriter];
}

@end

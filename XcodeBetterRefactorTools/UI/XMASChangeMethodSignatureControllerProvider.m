#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASChangeMethodSignatureController.h"
#import "XMASWindowProvider.h"
#import "XMASIndexedSymbolRepository.h"

@interface XMASChangeMethodSignatureControllerProvider ()
@property (nonatomic) XMASAlert *alerter;
@property (nonatomic) XMASWindowProvider *windowProvider;
@property (nonatomic) XMASIndexedSymbolRepository *indexedSymbolRepository;
@end

@implementation XMASChangeMethodSignatureControllerProvider

- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider
                               alerter:(XMASAlert *)alerter
               indexedSymbolRepository:(XMASIndexedSymbolRepository *)indexedSymbolRepository {
    if (self = [super init]) {
        self.alerter = alerter;
        self.windowProvider = windowProvider;
        self.indexedSymbolRepository = indexedSymbolRepository;
    }

    return self;
}

- (XMASChangeMethodSignatureController *)provideInstanceWithDelegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate {
    return [[XMASChangeMethodSignatureController alloc] initWithWindowProvider:self.windowProvider
                                                                      delegate:delegate
                                                                       alerter:self.alerter
                                                       indexedSymbolRepository:self.indexedSymbolRepository];
}

@end

#import "BetterRefactorToolsKitModule.h"
#import "KitSwiftCompatibilityHeader.h"

@implementation BetterRefactorToolsKitModule

- (void)configure:(id<BSBinder>)binder {
    [binder bind:[XMASParseSelectedProtocolUseCase class] toBlock:^id (NSArray *args, id<BSInjector> injector) {
        id<XMASSelectedProtocolOracle> oracle = [injector getInstance:@protocol(XMASSelectedProtocolOracle)];
        return [[XMASParseSelectedProtocolUseCase alloc] initWithProtocolOracle:oracle];
    }];
}

@end

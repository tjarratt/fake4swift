#import "BetterRefactorToolsKitModule.h"
#import "KitSwiftCompatibilityHeader.h"

@implementation BetterRefactorToolsKitModule

- (void)configure:(id<BSBinder>)binder {

    [binder bind:[XMASParseSelectedProtocolWorkFlow class] toBlock:^id (NSArray *args, id<BSInjector> injector) {
        id<XMASSelectedProtocolOracle> oracle = [injector getInstance:@protocol(XMASSelectedProtocolOracle)];
        return [[XMASParseSelectedProtocolWorkFlow alloc] initWithProtocolOracle:oracle];
    }];

    [binder bind:[XMASSwiftProtocolFaker class] toBlock:^id (NSArray *args, id<BSInjector> injector) {
        return [[XMASSwiftProtocolFaker alloc] initWithBundle:[injector getInstance:@"mustacheTemplateBundle"]];
    }];

    NSBundle *templateBundle = [NSBundle bundleForClass:[XMASSwiftProtocolFaker class]];
    [binder bind:@"mustacheTemplateBundle" toInstance:templateBundle];
}

@end

@import BetterRefactorToolsKit;

#import "XMASEditMenu.h"
#import "XMASRefactorMethodAction.h"
#import "XMASXcodeRepository.h"


@interface XMASEditMenu ()

@property (nonatomic) id<BSInjector> injector;

@end


@implementation XMASEditMenu

- (instancetype)initWithInjector:(id<BSInjector>)injector {
    if (self = [super init]) {
        self.injector = injector;
    }
    return self;
}

- (void)attach {
    XMASXcodeRepository *xcodeRepository = [self.injector getInstance:[XMASXcodeRepository class]];
    NSMenu *editMenu = [xcodeRepository menuWithTitle:@"Edit"];
    [editMenu addItem:NSMenuItem.separatorItem];
    [editMenu addItem:self.refactorCurrentMethodItem];
    [editMenu addItem:self.generateFakeForSwiftProtocolItem];
    [editMenu addItem:self.implementEquatableForSwiftStructItem];
}

#pragma mark - Menu items

- (NSMenuItem *)refactorCurrentMethodItem {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.title = @"Refactor Current Method";
    item.target = self;
    item.action = @selector(refactorCurrentMethodAction:);

    unichar f6Char = NSF6FunctionKey;
    item.keyEquivalent = [NSString stringWithCharacters:&f6Char length:1];
    item.keyEquivalentModifierMask = NSCommandKeyMask;
    return item;
}

- (NSMenuItem *)generateFakeForSwiftProtocolItem {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.title = @"Generate Fake Protocol";
    item.target = self;
    item.action = @selector(generateFakeAction:);

    item.keyEquivalent = @"g";
    item.keyEquivalentModifierMask = NSControlKeyMask;
    return item;
}

- (NSMenuItem *)implementEquatableForSwiftStructItem {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.title = @"Implement Equatable for Struct";
    item.target = self;
    item.action = @selector(implementEquatableAction:);

//    item.keyEquivalent = @"g";
//    item.keyEquivalentModifierMask = NSControlKeyMask;
    return item;
}

#pragma mark - Menu Actions

- (void)refactorCurrentMethodAction:(id)sender {
    XMASRefactorMethodAction *refactorAction = [self.injector getInstance:[XMASRefactorMethodAction class]];

    [refactorAction safelyRefactorMethodUnderCursor];
}

- (void)generateFakeAction:(id)sender {
    XMASGenerateFakeForSwiftProtocolUseCase *generateFakeAction = [self.injector getInstance:[XMASGenerateFakeForSwiftProtocolUseCase class]];

    [generateFakeAction safelyGenerateFakeForSelectedProtocol];
}

- (void)implementEquatableAction:(id)sender {
    XMASImplementEquatableUseCase *addEquatableUseCase = [self.injector getInstance:[XMASImplementEquatableUseCase class]];

    [addEquatableUseCase safelyAddEquatableToSelectedStruct];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

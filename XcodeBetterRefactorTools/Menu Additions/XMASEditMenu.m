#import "XMASEditMenu.h"
#import "XMASRefactorMethodAction.h"
#import "XMASXcodeRepository.h"
#import "XMASGenerateFakeAction.h"

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

#pragma mark - Menu Actions

- (void)refactorCurrentMethodAction:(id)sender {
    XMASRefactorMethodAction *refactorAction = [self.injector getInstance:[XMASRefactorMethodAction class]];

    [refactorAction safelyRefactorMethodUnderCursor];
}

- (void)generateFakeAction:(id)sender {
    XMASGenerateFakeAction *generateFakeAction = [self.injector getInstance:[XMASGenerateFakeAction class]];

    [generateFakeAction safelyGenerateFakeForSelectedProtocol];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

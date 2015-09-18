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

#pragma mark - Menu Actions

- (void)refactorCurrentMethodAction:(id)sender {
    XMASRefactorMethodAction *refactorAction = [self.injector getInstance:[XMASRefactorMethodAction class]];

    [refactorAction safelyRefactorMethodUnderCursor];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

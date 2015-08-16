#import "XMASEditMenu.h"
#import <Blindside/Blindside.h>
#import "XMASXcode.h"
#import "XMASRefactorMethodAction.h"
#import "XMASAlert.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASChangeMethodSignatureControllerProvider.h"
#import "XMASWindowProvider.h"
#import "XMASMethodOccurrencesRepository.h"
#import "XMASObjcCallExpressionRewriter.h"
#import "XMASObjcMethodCallParser.h"
#import "XMASObjcCallExpressionTokenFilter.h"
#import "XMASObjcCallExpressionStringWriter.h"
#import "XMASObjcMethodDeclarationRewriter.h"
#import "XMASObjcMethodDeclarationStringWriter.h"
#import "XMASTokenizer.h"
#import "XMASXcodeTargetSearchPathResolver.h"
#import "XMASSearchPathExpander.h"

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
    NSMenu *editMenu = [XMASXcode menuWithTitle:@"Edit"];
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

@end

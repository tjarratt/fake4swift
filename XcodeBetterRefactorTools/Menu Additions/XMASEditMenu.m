#import "XMASEditMenu.h"
#import "XMASXcode.h"
#import "XMASAlert.h"
#import <ClangKit/ClangKit.h>

@implementation XMASEditMenu

- (void)attach {
    NSMenu *editMenu = [XMASXcode menuWithTitle:@"Edit"];
    [editMenu addItem:NSMenuItem.separatorItem];
    [editMenu addItem:self.refactorCurrentMethodItem];
}

#pragma mark - Menu items

- (NSMenuItem *)refactorCurrentMethodItem {
    NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
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
    [XMASAlert flashMessage:@"SUP"];

    CKTranslationUnit *translationUnit = [CKTranslationUnit translationUnitWithPath:@"/Users/tjarratt/git/xcode-christmas-in-july/XcodeBetterRefactorTools/XMASBetterRefactorTools.m"];
    NSLog(@"================> %@", translationUnit.tokens);
}

@end

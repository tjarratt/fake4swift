#import <Blindside/Blindside.h>

#import "XMASBetterRefactorTools.h"
#import "RefactorToolsModule.h"
#import "XMASXcodeRepository.h"
#import "XcodeInterfaces.h"
#import "XMASEditMenu.h"

@interface XMASBetterRefactorTools ()

@property (nonatomic, retain) XMASEditMenu *editMenu;

@end


@implementation XMASBetterRefactorTools

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] init];
    });
}

- (id)init {
    if (self = [super init]) {
        [(NSNotificationCenter *)[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(applicationDidFinishLaunching:)
             name:NSApplicationDidFinishLaunchingNotification
             object:NSApp];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.editMenu = nil;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:NSApplicationDidFinishLaunchingNotification
         object:NSApp];

    id<BSInjector> injector = [Blindside injectorWithModule:[[RefactorToolsModule alloc] init]];
    self.editMenu = [[XMASEditMenu alloc] initWithInjector:injector];

    // attach menus on next tick of run loop to avoid clobbering existing menu items
    // e.g.: Jump To Instruction Pointer (https://github.com/cppforlife/CedarShortcuts/issues/19)
    [self performSelector:@selector(attachMenus) withObject:nil afterDelay:0.0f];
}

- (void)attachMenus {
    [self.editMenu attach];
}

@end

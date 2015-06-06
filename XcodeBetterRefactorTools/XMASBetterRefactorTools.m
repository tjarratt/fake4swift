#import "XMASBetterRefactorTools.h"
#import "XMASEditMenu.h"

@interface XMASBetterRefactorTools ()
@property (nonatomic, retain) XMASEditMenu *editMenu;
@end

@implementation XMASBetterRefactorTools

@synthesize editMenu = _editMenu;

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
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:NSApplicationDidFinishLaunchingNotification
         object:NSApp];

    self.editMenu = [[[XMASEditMenu alloc] init] autorelease];
    [self.editMenu attach];
}
@end

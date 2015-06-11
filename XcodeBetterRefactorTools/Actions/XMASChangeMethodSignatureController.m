#import "XMASChangeMethodSignatureController.h"
#import "XMASObjcSelectorParameter.h"

static NSString * const tableViewColumnRowIdentifier = @"";

@interface XMASChangeMethodSignatureController () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) NSWindow *window;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@property (nonatomic) XMASObjcSelector *method;
@property (nonatomic) NSString *filePath;

@end

@implementation XMASChangeMethodSignatureController

- (instancetype)initWithWindow:(NSWindow *)window {
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]]) {
        self.window = window;
    }

    return self;
}

- (void)refactorMethod:(XMASObjcSelector *)method inFile:(NSString *)filePath
{
    self.method = method;
    self.filePath = filePath;
    self.window.contentView = self.view;
}

#pragma mark - NSViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.window makeKeyAndOrderFront:NSApp];
}

#pragma mark - <NSTableViewDataSource>

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 22.0f;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return (NSInteger)self.method.components.count;
}

#pragma mark - <NSTableViewDelegate>

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextField *textField = [tableView makeViewWithIdentifier:tableViewColumnRowIdentifier owner:self];
    if (!textField) {
        textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
    }

    if ([tableColumn.identifier isEqualToString:@"selector"]) {
        textField.stringValue = self.method.components[(NSUInteger)row];
    } else if ([tableColumn.identifier isEqualToString:@"parameterType"]) {
        XMASObjcSelectorParameter *param = self.method.parameters[(NSUInteger)row];
        textField.stringValue = param.type;
    } else {
        XMASObjcSelectorParameter *param = self.method.parameters[(NSUInteger)row];
        textField.stringValue = param.localName;
    }

    return textField;
}

@end

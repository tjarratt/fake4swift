#import "XMASChangeMethodSignatureController.h"
#import "XMASObjcSelectorParameter.h"
#import "XMASWindowProvider.h"

static NSString * const tableViewColumnRowIdentifier = @"";

@interface XMASChangeMethodSignatureController () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSButton *addComponentButton;
@property (nonatomic, weak) IBOutlet NSButton *removeComponentButton;
@property (nonatomic, weak) IBOutlet NSButton *raiseComponentButton;
@property (nonatomic, weak) IBOutlet NSButton *lowerComponentButton;
@property (nonatomic, weak) IBOutlet NSButton *cancelButton;
@property (nonatomic, weak) IBOutlet NSButton *refactorButton;
@property (nonatomic, weak) IBOutlet NSTextField *previewTextField;

@property (nonatomic) XMASWindowProvider *windowProvider;
@property (nonatomic, weak) id <XMASChangeMethodSignatureControllerDelegate> delegate;

@property (nonatomic) XMASObjcSelector *method;
@property (nonatomic) NSString *filePath;

@end

@implementation XMASChangeMethodSignatureController

- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider
                              delegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate {
    NSBundle *bundleForClass = [NSBundle bundleForClass:[self class]];
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:bundleForClass]) {
        self.windowProvider = windowProvider;
        self.delegate = delegate;
    }

    return self;
}

- (void)refactorMethod:(XMASObjcSelector *)method inFile:(NSString *)filePath
{
    if (self.window == nil) {
        self.window = [self.windowProvider provideInstance];
        self.window.delegate = self;
        self.window.releasedWhenClosed = NO; // UGH HACK
    }

    self.method = method;
    self.filePath = filePath;

    self.window.contentView = self.view;
}

#pragma mark - IBActions

- (IBAction)didTapCancel:(id)sender {
    [self.window close];
}

- (IBAction)didTapRefactor:(id)sender {
    NSLog(@"================> %@", @"REFACTORD");
}

- (IBAction)didTapAdd:(id)sender {
    NSInteger selectedRow = self.tableView.selectedRow + 1;
    if (selectedRow == 0) {
        selectedRow = (NSInteger)self.method.components.count;
    }

    self.method = [self.method insertComponentAtIndex:(NSUInteger)selectedRow];
    [self.tableView reloadData];

    NSTextField *textField = (id)[self.tableView viewAtColumn:0 row:selectedRow makeIfNecessary:YES];
    textField.delegate = self;
    [textField becomeFirstResponder];

    self.previewTextField.stringValue = [self previewFromCurrentSelector];
}

- (IBAction)didTapRemove:(id)sender {
    NSInteger selectedRow = self.tableView.selectedRow;
    if (selectedRow == -1) {
        return;
    }

    self.method = [self.method deleteComponentAtIndex:(NSUInteger)selectedRow];
    [self.tableView reloadData];

    self.previewTextField.stringValue = [self previewFromCurrentSelector];
}

- (IBAction)didTapMoveUp:(id)sender {
    NSUInteger selectedRow = (NSUInteger)self.tableView.selectedRow;
    self.method = [self.method swapComponentAtIndex:selectedRow withComponentAtIndex:selectedRow - 1];
    [self.tableView reloadData];

    [self.tableView selectRowIndexes:[[NSIndexSet alloc] initWithIndex:(selectedRow - 1)] byExtendingSelection:NO];

    self.previewTextField.stringValue = [self previewFromCurrentSelector];
}

- (IBAction)didTapMoveDown:(id)sender {
    NSUInteger selectedRow = (NSUInteger)self.tableView.selectedRow;
    self.method = [self.method swapComponentAtIndex:selectedRow withComponentAtIndex:selectedRow + 1];
    [self.tableView reloadData];

    [self.tableView selectRowIndexes:[[NSIndexSet alloc] initWithIndex:(selectedRow + 1)] byExtendingSelection:NO];

    self.previewTextField.stringValue = [self previewFromCurrentSelector];
}

#pragma mark - <NSWindowDelegate>

- (void)windowWillClose:(NSNotification *)notification
{
    self.window.delegate = nil;
    self.window = nil;
    [self.delegate controllerWillDisappear:self];
}

#pragma mark - NSViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.raiseComponentButton.enabled = NO;
    self.lowerComponentButton.enabled = NO;

    self.previewTextField.stringValue = [self previewFromCurrentSelector];

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
        textField.delegate = self;
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

-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selectedRow = self.tableView.selectedRow;
    self.lowerComponentButton.enabled = selectedRow >= 0 && selectedRow < (self.method.components.count - 1);
    self.raiseComponentButton.enabled = selectedRow > 0 && selectedRow <= (self.method.components.count - 1);
}

#pragma mark - <NSTextfieldDelegate>

- (void)controlTextDidChange:(NSNotification *)notification {
    for (NSUInteger row = 0; row < self.method.components.count; ++row) {
        for (NSUInteger column = 0; column < 3; ++column) {
            NSTextField *textField = (id)[self.tableView viewAtColumn:(NSInteger)column row:(NSInteger)row makeIfNecessary:YES];
            if (textField == notification.object) {
                switch (column) {
                    case 0:
                        self.method = [self.method changeSelectorNameAtIndex:row to:textField.stringValue];
                        break;
                    case 1:
                        self.method = [self.method changeParameterTypeAtIndex:row to:textField.stringValue];
                        break;
                    case 2:
                        self.method = [self.method changeParameterLocalNameAtIndex:row to:textField.stringValue];
                        break;
                }

                self.previewTextField.stringValue = [self previewFromCurrentSelector];
                return;
            }
        }
    }
}

#pragma mark - Private

- (NSString *)previewFromCurrentSelector {
    NSMutableArray *pieces = [[NSMutableArray alloc] initWithCapacity:self.method.components.count];
    for (NSUInteger i = 0; i < self.method.components.count; ++i) {
        NSString *componentName = self.method.components[i];
        XMASObjcSelectorParameter *param = self.method.parameters[i];

        [pieces addObject:[NSString stringWithFormat:@"%@:(%@)%@", componentName, param.type, param.localName]];
    }

    return [NSString stringWithFormat:@"- (%@)%@", self.method.returnType, [pieces componentsJoinedByString:@" "]];
}

@end

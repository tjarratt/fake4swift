#import "XMASChangeMethodSignatureController.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XMASWindowProvider.h"
#import "XMASXcode.h"
#import "XcodeInterfaces.h"
#import "XMASAlert.h"
#import "XMASIndexedSymbolRepository.h"
#import "XMASObjcCallExpressionRewriter.h"
#import "XMASObjcCallExpressionStringWriter.h"

static NSString * const tableViewColumnRowIdentifier = @"";

@interface XMASChangeMethodSignatureController ()

@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableviewHeight;
@property (nonatomic, weak) IBOutlet NSButton *addComponentButton;
@property (nonatomic, weak) IBOutlet NSButton *removeComponentButton;
@property (nonatomic, weak) IBOutlet NSButton *raiseComponentButton;
@property (nonatomic, weak) IBOutlet NSButton *lowerComponentButton;
@property (nonatomic, weak) IBOutlet NSButton *cancelButton;
@property (nonatomic, weak) IBOutlet NSButton *refactorButton;
@property (nonatomic, weak) IBOutlet NSTextField *previewTextField;

@property (nonatomic) XMASAlert *alerter;
@property (nonatomic) XMASWindowProvider *windowProvider;
@property (nonatomic) XMASIndexedSymbolRepository *indexedSymbolRepository;
@property (nonatomic) XMASObjcCallExpressionRewriter *callExpressionRewriter;
@property (nonatomic) XMASObjcCallExpressionStringWriter *callExpressionStringWriter;
@property (nonatomic, weak) id <XMASChangeMethodSignatureControllerDelegate> delegate;

@property (nonatomic) XMASObjcMethodDeclaration *originalMethod;
@property (nonatomic) XMASObjcMethodDeclaration *method;
@property (nonatomic) NSString *filePath;

@end

@implementation XMASChangeMethodSignatureController

- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider
                              delegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate
                               alerter:(XMASAlert *)alerter
               indexedSymbolRepository:(XMASIndexedSymbolRepository *)indexedSymbolRepository
                callExpressionRewriter:(XMASObjcCallExpressionRewriter *)callExpressionRewriter
            callExpressionStringWriter:(XMASObjcCallExpressionStringWriter *)callExpressionStringWriter {
    NSBundle *bundleForClass = [NSBundle bundleForClass:[self class]];
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:bundleForClass]) {
        self.alerter = alerter;
        self.windowProvider = windowProvider;
        self.indexedSymbolRepository = indexedSymbolRepository;
        self.callExpressionRewriter = callExpressionRewriter;
        self.callExpressionStringWriter = callExpressionStringWriter;
        self.delegate = delegate;
    }

    return self;
}

- (void)refactorMethod:(XMASObjcMethodDeclaration *)method inFile:(NSString *)filePath
{
    if (self.window == nil) {
        self.window = [self.windowProvider provideInstance];
        self.window.delegate = self;
        self.window.releasedWhenClosed = NO; // UGH HACK
    }

    self.method = method;
    self.originalMethod = method;
    self.filePath = filePath;

    self.window.contentView = self.view;
}

#pragma mark - IBActions

- (IBAction)didTapCancel:(id)sender {
    [self.window close];
}

- (IBAction)didTapRefactor:(id)sender {
    @try {
        [self didTapRefactorActionPossiblyRaisingException];
    }
    @catch (NSException *exception) {
        [self.alerter flashComfortingMessageForException:exception];
    }
}

- (IBAction)didTapAdd:(id)sender {
    NSInteger selectedRow = self.tableView.selectedRow + 1;
    if (selectedRow == 0) {
        selectedRow = (NSInteger)self.method.components.count;
    }

    self.method = [self.method insertComponentAtIndex:(NSUInteger)selectedRow];
    [self.tableView reloadData];
    [self resizeTableview];

    NSTextField *textField = (id)[self.tableView viewAtColumn:0 row:selectedRow makeIfNecessary:YES];
    textField.delegate = self;
    [textField becomeFirstResponder];

    self.previewTextField.stringValue = [self.callExpressionStringWriter formatInstanceMethodDeclaration:self.method];
}

- (IBAction)didTapRemove:(id)sender {
    NSInteger selectedRow = self.tableView.selectedRow;
    if (selectedRow == -1) {
        return;
    }

    self.method = [self.method deleteComponentAtIndex:(NSUInteger)selectedRow];
    [self.tableView reloadData];
    [self resizeTableview];

    self.previewTextField.stringValue = [self.callExpressionStringWriter formatInstanceMethodDeclaration:self.method];
}

- (IBAction)didTapMoveUp:(id)sender {
    NSUInteger selectedRow = (NSUInteger)self.tableView.selectedRow;
    self.method = [self.method swapComponentAtIndex:selectedRow withComponentAtIndex:selectedRow - 1];
    
    [self.tableView reloadData];
    [self.tableView selectRowIndexes:[[NSIndexSet alloc] initWithIndex:(selectedRow - 1)] byExtendingSelection:NO];

    self.previewTextField.stringValue = [self.callExpressionStringWriter formatInstanceMethodDeclaration:self.method];
}

- (IBAction)didTapMoveDown:(id)sender {
    NSUInteger selectedRow = (NSUInteger)self.tableView.selectedRow;
    self.method = [self.method swapComponentAtIndex:selectedRow withComponentAtIndex:selectedRow + 1];

    [self.tableView reloadData];
    [self.tableView selectRowIndexes:[[NSIndexSet alloc] initWithIndex:(selectedRow + 1)] byExtendingSelection:NO];

    self.previewTextField.stringValue = [self.callExpressionStringWriter formatInstanceMethodDeclaration:self.method];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
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
    self.tableView.intercellSpacing = NSMakeSize(0, 0);

    [self resizeTableview];

    self.raiseComponentButton.enabled = NO;
    self.lowerComponentButton.enabled = NO;

    self.previewTextField.stringValue = [self.callExpressionStringWriter formatInstanceMethodDeclaration:self.method];

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
        textField.font = [NSFont fontWithName:@"Menlo" size:13.0f];
    }

    if ([tableColumn.identifier isEqualToString:@"selector"]) {
        textField.stringValue = self.method.components[(NSUInteger)row];
    } else if ([tableColumn.identifier isEqualToString:@"parameterType"]) {
        XMASObjcMethodDeclarationParameter *param = self.method.parameters[(NSUInteger)row];
        textField.stringValue = param.type;
    } else {
        XMASObjcMethodDeclarationParameter *param = self.method.parameters[(NSUInteger)row];
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

                self.previewTextField.stringValue = [self.callExpressionStringWriter formatInstanceMethodDeclaration:self.method];
                return;
            }
        }
    }
}

#pragma mark - Private

- (void)didTapRefactorActionPossiblyRaisingException {
    NSArray *symbols = [self.indexedSymbolRepository callSitesOfCurrentlySelectedMethod];
    NSString *message = [NSString stringWithFormat:@"Changing %lu call sites of %@", symbols.count, self.originalMethod.selectorString];
    [self.alerter flashMessage:message withLogging:YES];

    for (XC(IDEIndexSymbol) symbol in symbols) {
        [self.callExpressionRewriter changeCallsite:symbol
                                         fromMethod:self.originalMethod
                                        toNewMethod:self.method];
    }
}

- (void)resizeTableview {
    CGFloat headerHeight = CGRectGetHeight(self.tableView.headerView.frame) + 1;
    CGFloat rowHeight = self.tableView.rowHeight;

    NSInteger numberOfRows = [self numberOfRowsInTableView:self.tableView];
    CGFloat tableviewHeight = headerHeight + numberOfRows * (rowHeight + 5);

    self.tableviewHeight.constant = tableviewHeight;
}

@end

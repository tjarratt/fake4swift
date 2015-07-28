#import "XMASIndexedSymbolRepository.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASXcode.h"

@interface XMASIndexedSymbolRepository ()
@property (nonatomic) XC(IDEWorkspaceWindowController) workspaceWindowController;
@end

@implementation XMASIndexedSymbolRepository

- (instancetype)initWithWorkspaceWindowController:(XC(IDEWorkspaceWindowController))workspaceWindowController {
    if (self = [super init]) {
        self.workspaceWindowController = workspaceWindowController;
    }

    return self;
}

- (NSArray *)callSitesOfCurrentlySelectedMethod {
    id editorContext = [[self.workspaceWindowController editorArea] lastActiveEditorContext];
    NSArray *geniusSourceCodeCallerResults = [XMASXcode geniusCallerResultsForEditorContext:editorContext];

    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (XC(IDESourceCodeCallerGeniusResult) sourceCodeCallerResult in geniusSourceCodeCallerResults) {
        [results addObject:[sourceCodeCallerResult valueForKey:@"calleeSymbolOccurrence"]];
    }

    return results;
}

@end

#import "XMASMethodOccurrencesRepository.h"
#import "XMASObjcMethodDeclaration.h"
#import "XcodeInterfaces.h"
#import "XMASXcodeRepository.h"

@interface XMASMethodOccurrencesRepository ()
@property (nonatomic) XC(IDEWorkspaceWindowController) workspaceWindowController;
@property (nonatomic) XMASXcodeRepository *xcodeRepository;
@end

@implementation XMASMethodOccurrencesRepository

- (instancetype)initWithWorkspaceWindowController:(XC(IDEWorkspaceWindowController))workspaceWindowController
                                  xcodeRepository:(XMASXcodeRepository *)xcodeRepository {
    if (self = [super init]) {
        self.xcodeRepository = xcodeRepository;
        self.workspaceWindowController = workspaceWindowController;
    }

    return self;
}

- (NSSet *)callSitesOfCurrentlySelectedMethod {
    id editorContext = [[self.workspaceWindowController editorArea] lastActiveEditorContext];
    NSArray *geniusSourceCodeCallerResults = [self.xcodeRepository geniusCallerResultsForEditorContext:editorContext];

    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (XC(IDESourceCodeCallerGeniusResult) sourceCodeCallerResult in geniusSourceCodeCallerResults) {
        [results addObject:[sourceCodeCallerResult valueForKey:@"calleeSymbolOccurrence"]];
    }

    return [NSSet setWithArray:results];
}

- (NSSet *)forwardDeclarationsOfMethod:(XMASObjcMethodDeclaration *)methodDeclaration {
    NSMutableArray *matchingSymbols = [[NSMutableArray alloc] init];
    NSArray *instanceMethodSymbols = [self.xcodeRepository instanceMethodSymbolsInWorkspace];
    for (XC(IDEIndexSymbol) symbol in instanceMethodSymbols) {
        if ([[symbol name] isEqualToString:methodDeclaration.selectorString]) {
            [matchingSymbols addObject:symbol];
        }
    }

    return [NSSet setWithArray:matchingSymbols];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

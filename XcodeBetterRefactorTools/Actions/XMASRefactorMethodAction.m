#import "XMASRefactorMethodAction.h"
#import <ClangKit/ClangKit.h>
#import "XcodeInterfaces.h"
#import "XMASAlert.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASObjcSelector.h"

NSString * const noMethodSelected = @"No method selected. Put your cursor inside of a method declaration";

@interface XMASRefactorMethodAction ()
@property (nonatomic) id currentEditor;
@property (nonatomic) XMASAlert *alerter;
@property (nonatomic) XMASObjcMethodDeclarationParser *methodDeclParser;
@end

@implementation XMASRefactorMethodAction

- (instancetype)initWithEditor:(id)editor
                       alerter:(XMASAlert *)alerter
              methodDeclParser:(XMASObjcMethodDeclarationParser *)methodDeclParser {
    if (self = [super init]) {
        self.currentEditor = editor;
        self.alerter = alerter;
        self.methodDeclParser = methodDeclParser;
    }

    return self;
}

- (void)refactorMethodUnderCursor {
    NSUInteger cursorLocation = [self cursorLocation];
    CKTranslationUnit *translationUnit = [CKTranslationUnit translationUnitWithPath:[self currentSourceCodeFilePath]];
    NSArray *selectors = [self.methodDeclParser parseMethodDeclarationsFromTokens:translationUnit.tokens];

    XMASObjcSelector *selectedMethod;
    for (XMASObjcSelector *selector in selectors) {
        if (cursorLocation > selector.range.location && cursorLocation < selector.range.location + selector.range.length) {
            selectedMethod = selector;
            break;
        }
    }

    if (!selectedMethod) {
        [self.alerter flashMessage:noMethodSelected];
        return;
    }

    [self.alerter flashMessage:selectedMethod.selectorString];
}

#pragma mark - editor helpers

- (NSString *)currentSourceCodeFilePath {
    if ([self.currentEditor respondsToSelector:@selector(sourceCodeDocument)]) {
        return [[[self.currentEditor sourceCodeDocument] fileURL] path];
    }
    return nil;
}

- (NSUInteger)cursorLocation {
    XC(DVTTextDocumentLocation) currentLocation = [[self.currentEditor currentSelectedDocumentLocations] lastObject];
    return currentLocation.characterRange.location;
}

@end

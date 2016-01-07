@import BetterRefactorToolsKit;
#import <ClangKit/ClangKit.h>

#import "XMASObjcMethodDeclarationRewriter.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationStringWriter.h"
#import "XMASObjcMethodDeclarationParser.h"
#import "XMASTokenizer.h"

@interface XMASObjcMethodDeclarationRewriter ()
@property (nonatomic) id<XMASAlerter> alerter;
@property (nonatomic) XMASTokenizer *tokenizer;
@property (nonatomic) XMASObjcMethodDeclarationParser *methodDeclarationParser;
@property (nonatomic) XMASObjcMethodDeclarationStringWriter *methodDeclarationStringWriter;
@end

@implementation XMASObjcMethodDeclarationRewriter

- (instancetype)initWithMethodDeclarationStringWriter:(XMASObjcMethodDeclarationStringWriter *)methodDeclarationStringWriter
                              methodDeclarationParser:(XMASObjcMethodDeclarationParser *)methodDeclarationParser
                                            tokenizer:(XMASTokenizer *)tokenizer
                                              alerter:(id<XMASAlerter>)alerter {
    if (self = [super init]) {
        self.alerter = alerter;
        self.tokenizer = tokenizer;
        self.methodDeclarationStringWriter = methodDeclarationStringWriter;
        self.methodDeclarationParser = methodDeclarationParser;
    }

    return self;
}

- (void)changeMethodDeclaration:(XMASObjcMethodDeclaration *)oldMethodDeclaration
                    toNewMethod:(XMASObjcMethodDeclaration *)newMethodDeclaration
                         inFile:(NSString *)filePath {
    NSString *methodDeclString = [self.methodDeclarationStringWriter formatInstanceMethodDeclaration:newMethodDeclaration];

    NSStringEncoding stringEncoding;
    NSString *oldFileContents = [NSString stringWithContentsOfFile:filePath
                                                          usedEncoding:&stringEncoding
                                                             error:nil];
    NSString *newFileContents = [oldFileContents stringByReplacingCharactersInRange:oldMethodDeclaration.range
                                                                         withString:methodDeclString];
    [newFileContents writeToFile:filePath
                      atomically:YES
                        encoding:stringEncoding
                           error:nil];
}

- (void)changeMethodDeclarationForSymbol:(XC(IDEIndexSymbol))symbol
                                toMethod:(XMASObjcMethodDeclaration *)newMethodDeclaration {
    NSString *fileToRewrite = symbol.file.pathString;
    NSArray *tokens = [self.tokenizer tokensForFilePath:fileToRewrite];
    NSArray *methodDeclarationsInFile = [self.methodDeclarationParser parseMethodDeclarationsFromTokens:tokens];

    XMASObjcMethodDeclaration *methodDeclarationToRewrite;
    for (XMASObjcMethodDeclaration *methodDeclaration in methodDeclarationsInFile) {
        BOOL matchingLineNumber = methodDeclaration.lineNumber == symbol.lineNumber;
        BOOL matchingColumnNumber = methodDeclaration.columnNumber == symbol.column;
        if (matchingLineNumber && matchingColumnNumber) {
            methodDeclarationToRewrite = methodDeclaration;
            break;
        }
    }

    if (!methodDeclarationToRewrite) {
        NSString *helpfulMessage = [NSString stringWithFormat:@"Aww shucks. Couldn't find '%@' in '%@' at line %lu column %lu", newMethodDeclaration.selectorString, fileToRewrite.lastPathComponent, symbol.lineNumber, symbol.column];
        [self.alerter flashMessage:helpfulMessage
                         withImage:XMASAlertImageAbjectFailure
                  shouldLogMessage:NO];
        return;
    }

    NSStringEncoding usedEncoding;
    NSString *oldFileContents = [NSString stringWithContentsOfFile:fileToRewrite
                                                      usedEncoding:&usedEncoding
                                                             error:nil];

    NSString *methodDeclString = [self.methodDeclarationStringWriter formatInstanceMethodDeclaration:newMethodDeclaration];
    NSString *refactoredFile = [oldFileContents stringByReplacingCharactersInRange:methodDeclarationToRewrite.range
                                                                        withString:methodDeclString];
    [refactoredFile writeToFile:fileToRewrite
                     atomically:YES
                       encoding:usedEncoding
                          error:nil];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

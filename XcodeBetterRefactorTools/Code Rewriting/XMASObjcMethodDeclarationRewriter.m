#import "XMASObjcMethodDeclarationRewriter.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationStringWriter.h"
#import "XMASObjcMethodDeclarationParser.h"
#import <ClangKit/ClangKit.h>
#import "XMASAlert.h"
#import "XMASTokenizer.h"

@interface XMASObjcMethodDeclarationRewriter ()
@property (nonatomic) XMASAlert *alerter;
@property (nonatomic) XMASTokenizer *tokenizer;
@property (nonatomic) XMASObjcMethodDeclarationParser *methodDeclarationParser;
@property (nonatomic) XMASObjcMethodDeclarationStringWriter *methodDeclarationStringWriter;
@end

@implementation XMASObjcMethodDeclarationRewriter

- (instancetype)initWithMethodDeclarationStringWriter:(XMASObjcMethodDeclarationStringWriter *)methodDeclarationStringWriter
                              methodDeclarationParser:(XMASObjcMethodDeclarationParser *)methodDeclarationParser
                                            tokenizer:(XMASTokenizer *)tokenizer
                                              alerter:(XMASAlert *)alerter {
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

    NSString *oldFileContents = [NSString stringWithContentsOfFile:filePath
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
    NSString *newFileContents = [oldFileContents stringByReplacingCharactersInRange:oldMethodDeclaration.range
                                                                         withString:methodDeclString];
    [newFileContents writeToFile:filePath
                      atomically:YES
                        encoding:NSUTF8StringEncoding
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
        [self.alerter flashMessage:helpfulMessage];
        return;
    }

    NSString *oldFileContents = [NSString stringWithContentsOfFile:fileToRewrite
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];

    NSString *methodDeclString = [self.methodDeclarationStringWriter formatInstanceMethodDeclaration:newMethodDeclaration];
    NSString *refactoredFile = [oldFileContents stringByReplacingCharactersInRange:methodDeclarationToRewrite.range
                                                                        withString:methodDeclString];
    [refactoredFile writeToFile:fileToRewrite
                     atomically:YES
                       encoding:NSUTF8StringEncoding
                          error:nil];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

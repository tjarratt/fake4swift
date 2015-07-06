#import "XMASObjcMethodDeclarationParser.h"
#import "XMASObjcMethodDeclaration.h"
#import <ClangKit/ClangKit.h>

@implementation XMASObjcMethodDeclarationParser

- (NSArray *)parseMethodDeclarationsFromTokens:(NSArray *)tokens {
    NSMutableArray *methodDeclarations = [NSMutableArray array];

    CKToken *token;
    for (NSUInteger i = 0; i < tokens.count; ++i) {
        token = tokens[i];
        if (![self isMethodDeclarationToken:token]) {
            continue;
        }

        // retrieve all of the tokens that make up the method declaration
        NSMutableArray *methodDeclTokens = [NSMutableArray array];
        while (i < tokens.count && [self isValidTokenInsideMethodDeclaration:tokens[i]]) {
            [methodDeclTokens addObject:tokens[i]];
            ++i;
        }

        XMASObjcMethodDeclaration *selector = [[XMASObjcMethodDeclaration alloc] initWithTokens:methodDeclTokens];
        [methodDeclarations addObject:selector];
    }

    return methodDeclarations;
}

#pragma mark - Private

- (BOOL)isMethodDeclarationToken:(CKToken *)token {
    BOOL isClassMethod = token.cursor.kind == CKCursorKindObjCClassMethodDecl;
    BOOL isInstanceMethod = token.cursor.kind == CKCursorKindObjCInstanceMethodDecl;
    BOOL isSemicolon = token.kind == CKTokenKindPunctuation && [token.spelling isEqualToString:@";"];

    return (isInstanceMethod || isClassMethod) && !isSemicolon;
}

- (BOOL)isValidTokenInsideMethodDeclaration:(CKToken *)token {
    if ([self isMethodDeclarationToken:token]) {
        return YES;
    }

    BOOL isParameterDeclaration = token.cursor.kind == CKCursorKindParmDecl;
    BOOL isTypeDeclaration = token.cursor.kind == CKCursorKindTypeRef;
    BOOL isObjcClassDeclaration = token.cursor.kind == CKCursorKindObjCClassRef;
    BOOL isPossibleIBAction = token.cursor.kind == CKCursorKindMacroExpansion;

    return isParameterDeclaration || isTypeDeclaration || isObjcClassDeclaration || isPossibleIBAction;
}

@end

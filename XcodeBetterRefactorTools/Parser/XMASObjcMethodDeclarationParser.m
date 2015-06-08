#import "XMASObjcMethodDeclarationParser.h"
#import "XMASObjcSelector.h"
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

        // continue reading until we have the return type
        while (i < tokens.count) {
            token = tokens[i];
            if (token.kind == CKTokenKindPunctuation && [token.spelling isEqualToString:@")"]) {
                break;
            }
            ++i;
        }
        ++i;

        // retrieve all of the tokens that make up the method declaration
        NSMutableArray *methodDeclTokens = [NSMutableArray array];
        while (i < tokens.count && [self isValidTokenInsideMethodDeclaration:tokens[i]]) {
            [methodDeclTokens addObject:tokens[i]];
            ++i;
        }

        XMASObjcSelector *selector = [[XMASObjcSelector alloc] initWithTokens:methodDeclTokens];
        [methodDeclarations addObject:selector];
    }

    return methodDeclarations;
}

#pragma mark - Private

- (BOOL)isMethodDeclarationToken:(CKToken *)token {
    BOOL isClassMethod = token.cursor.kind == CKCursorKindObjCClassMethodDecl;
    BOOL isInstanceMethod = token.cursor.kind == CKCursorKindObjCInstanceMethodDecl;

    return isInstanceMethod || isClassMethod;
}

- (BOOL)isValidTokenInsideMethodDeclaration:(CKToken *)token {
    if ([self isMethodDeclarationToken:token]) {
        return YES;
    }

    BOOL isParameterDeclaration = token.cursor.kind == CKCursorKindParmDecl;
    BOOL isTypeDeclaration = token.cursor.kind == CKCursorKindTypeRef;
    BOOL isObjcClassDeclaration = token.cursor.kind == CKCursorKindObjCClassRef;

    return isParameterDeclaration || isTypeDeclaration || isObjcClassDeclaration;
}

@end

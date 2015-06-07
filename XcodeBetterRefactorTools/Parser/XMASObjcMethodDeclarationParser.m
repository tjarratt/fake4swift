#import "XMASObjcMethodDeclarationParser.h"
#import <ClangKit/ClangKit.h>

@implementation XMASObjcMethodDeclarationParser

- (NSArray *)parseMethodDeclarationsFromTokens:(NSArray *)tokens {
    NSMutableArray *methodDeclTokens = [NSMutableArray array];

    CKToken *token;
    for (NSUInteger i = 0; i < tokens.count; ++i) {
        token = tokens[i];
        if (![self isMethodDeclarationToken:token]) {
            continue;
        }

        // continue until we have the return type
        while (i < tokens.count) {
            token = tokens[i];
            if (token.kind == CKTokenKindPunctuation && [token.spelling isEqualToString:@")"]) {
                break;
            }
            ++i;
        }
        ++i;

        token = tokens[i];
        [methodDeclTokens addObject:token];

        // continue until we are outside the method declaration
        while ([self isMethodDeclarationToken:token] && i < tokens.count) {
            ++i;
            token = tokens[i];
        }
    }

    return methodDeclTokens;
}

#pragma mark - Private

- (BOOL)isMethodDeclarationToken:(CKToken *)token {
    BOOL isClassMethod = token.cursor.kind == CKCursorKindObjCClassMethodDecl;
    BOOL isInstanceMethod = token.cursor.kind == CKCursorKindObjCInstanceMethodDecl;

    return isInstanceMethod || isClassMethod;
}

@end

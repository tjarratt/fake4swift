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

        // continue until we have the return type
        while (i < tokens.count) {
            token = tokens[i];
            if (token.kind == CKTokenKindPunctuation && [token.spelling isEqualToString:@")"]) {
                break;
            }
            ++i;
        }
        ++i;

        NSMutableArray *methodDeclTokens = [NSMutableArray array];
        while (i < tokens.count && [self isMethodDeclarationToken:tokens[i]]) {
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

@end

#import "XMASObjcMethodCallparser.h"
#import <ClangKit/ClangKit.h>

@implementation XMASObjcMethodCallParser

- (NSArray *)parseMethodCallsFromTokens:(NSArray *)tokens
                       matchingSelector:(NSString *)selectorName {

    NSMutableArray *methodCalls = [[NSMutableArray alloc] init];
    NSUInteger count = tokens.count;

    for (NSUInteger i = 0; i < count; ++i) {
        CKToken *token = tokens[i];
        NSLog(@"================> %@ -- %ld", token, (long)token.cursor.kind);
        NSMutableArray *selectorComponents = [[NSMutableArray alloc] init];
        if (token.cursor.kind == CKCursorKindObjCMessageExpr) {
            for (; i < count; ++i) {
                token = tokens[i];
                if ([self isEndOfMethodCallToken:token]) {
                    break;
                }
                if (![self isSelectorComponentToken:token]) {
                    continue;
                }

                [selectorComponents addObject:token.spelling];

                i++;
                for (; i < count; ++i) {
                    token = tokens[i];
                    if ([self isEndOfMethodCallToken:token]) {
                        --i;
                        break;
                    }

                    if ([self isSelectorComponentToken:token]) {
                        --i;
                        break;
                    }
                }
            }
        }

        NSString *joinedComponents = [selectorComponents componentsJoinedByString:@":"];
        NSString *parsedSelector = selectorComponents.count > 1 ? [joinedComponents stringByAppendingString:@":"] : joinedComponents;
        if ([parsedSelector isEqualToString:selectorName]) {
            [methodCalls addObject:[NSNull null]];
        }
    }

    return methodCalls;
}

#pragma mark - Private

- (BOOL)isEndOfMethodCallToken:(CKToken *)token {
    BOOL isPunctuation = token.kind == CKTokenKindPunctuation;
    BOOL isClosingSquareBracket = [token.spelling isEqualToString:@"]"];
    BOOL isObjcMessageExpr = token.cursor.kind == CKCursorKindObjCMessageExpr;
    return isPunctuation && isClosingSquareBracket && isObjcMessageExpr;
}

- (BOOL)isSelectorComponentToken:(CKToken *)token {
    // does this need to check if the following token is a colon?
    return token.kind == CKTokenKindIdentifier && token.cursor.kind == CKCursorKindObjCMessageExpr;
}

@end

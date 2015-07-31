#import "XMASObjcCallExpressionTokenFilter.h"
#import <ClangKit/ClangKit.h>

@implementation XMASObjcCallExpressionTokenFilter

- (NSSet *)parseCallExpressionRangesFromTokens:(NSArray *)tokens {
    return [self parseCallExpressionRangesFromTokens:tokens
                                     startingAtIndex:0
                                     stoppingAtIndex:tokens.count];
}

#pragma mark - Private

- (NSSet *)parseCallExpressionRangesFromTokens:(NSArray *)tokens
                               startingAtIndex:(NSUInteger)startIndex
                               stoppingAtIndex:(NSUInteger)stopIndex {

    NSMutableSet *callExpressionRanges = [[NSMutableSet alloc] init];
    NSAssert(stopIndex <= tokens.count, @"Index to stop at MUST be less than or equal to number of tokens to parse");

    for (NSUInteger index = startIndex; index < stopIndex; ++index) {
        CKToken *token = tokens[index];
        if (![self isStartOfMethodCallExpression:token]) {
            continue;
        }

        NSUInteger indexOfClosingBracket = [self indexOfMatchingClosingTokenForCallExpressionAtIndex:index fromTokens:tokens];
        NSRange callExpressionRange = NSMakeRange(index, indexOfClosingBracket - index + 1);
        [callExpressionRanges addObject:[NSValue valueWithRange:callExpressionRange]];

        // only parse the inner tokens, looking for [[nested call] expressions];
        NSSet *nestedCallExprs = [self parseCallExpressionRangesFromTokens:tokens startingAtIndex:index + 1 stoppingAtIndex:indexOfClosingBracket];
        [callExpressionRanges addObjectsFromArray:nestedCallExprs.allObjects];
        index = indexOfClosingBracket;
    }

    return callExpressionRanges;
}


- (BOOL)isStartOfMethodCallExpression:(CKToken *)token {
    if (![token.spelling isEqualToString:@"["]) {
        return NO;
    }

    if (token.cursor.kind == CKCursorKindObjCMessageExpr || token.cursor.kind == CKCursorKindDeclStmt) {
        return YES;
    }

    return NO;
}

- (NSUInteger)indexOfMatchingClosingTokenForCallExpressionAtIndex:(NSUInteger)index
                                                      fromTokens:(NSArray *)tokens {
    NSUInteger countOfOpenBrackets = 0;
    for (; index < tokens.count; ++index) {
        CKToken *token = tokens[index];
        if ([token.spelling isEqualToString:@"["]) {
            ++countOfOpenBrackets;
            continue;
        } else if ([token.spelling isEqualToString:@"]"]) {
            --countOfOpenBrackets;
        }

        if (countOfOpenBrackets == 0) {
            return index;
        }
    }

    return NSNotFound;
}

@end

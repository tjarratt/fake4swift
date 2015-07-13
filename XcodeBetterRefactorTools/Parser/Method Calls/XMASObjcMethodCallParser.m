#import "XMASObjcMethodCallparser.h"
#import <ClangKit/ClangKit.h>
#import <ClangKit/CKCursor.h>
#import "XMASObjcMethodCall.h"

@interface XMASObjcMethodCallParser ()
@property (nonatomic) NSMutableArray *methodCalls;
@end

@implementation XMASObjcMethodCallParser

- (NSArray *)parseMethodCallsFromTokens:(NSArray *)tokens
                       matchingSelector:(NSString *)selectorName
                                 inFile:(NSString *)filePath {

    NSMutableArray *methodCalls = [[NSMutableArray alloc] init];
    NSUInteger count = tokens.count;

    for (NSUInteger i = 0; i < count; ++i) {
        CKToken *token = tokens[i];
        NSMutableArray *selectorComponentTokens = [[NSMutableArray alloc] init];
        NSMutableArray *argumentStrings = [[NSMutableArray alloc] init];
        NSMutableArray *argumentTokens = [[NSMutableArray alloc] init];

        if (![self isStartOfMethodCallExpression:token]) {
            continue;
        }

        if (token.cursor.kind == CKCursorKindDeclStmt) {
            // keep going until we have seen the target of the call expression
            while (i < count && token.kind != CKTokenKindIdentifier) {
                ++i;
                token = tokens[i];
            }
            ++i;
            if (i >= count) {
                break;
            }
            token = tokens[i];
        }

        for (; i < count; ++i) {
            token = tokens[i];
            if ([self isEndOfMethodCallToken:token]) {
                break;
            }
            if (![self isSelectorComponentToken:token]) {
                continue;
            }

            [selectorComponentTokens addObject:token];

            i++;
            NSMutableArray *currentArgumentTokens = [[NSMutableArray alloc] init];
            for (; i < count; ++i) {
                token = tokens[i];
                if ([token.spelling isEqualToString:@":"] && token.kind == CKTokenKindPunctuation) {
                    continue;
                }

                if ([self isEndOfMethodCallToken:token]) {
                    NSArray *currentArgumentPieces = [currentArgumentTokens valueForKey:@"spelling"];
                    [argumentStrings addObject:[currentArgumentPieces componentsJoinedByString:@""]];
                    --i;
                    break;
                }

                if ([self isSelectorComponentToken:token]) {
                    NSArray *currentArgumentPieces = [currentArgumentTokens valueForKey:@"spelling"];
                    [argumentStrings addObject:[currentArgumentPieces componentsJoinedByString:@""]];
                    --i;
                    break;
                }

                [currentArgumentTokens addObject:token];
                [argumentTokens addObject:token];
            }
        }

        NSArray *selectorComponents = [selectorComponentTokens valueForKey:@"spelling"];
        NSString *joinedComponents = [selectorComponents componentsJoinedByString:@":"];
        NSString *parsedSelector = argumentTokens.count > 0 ? [joinedComponents stringByAppendingString:@":"] : joinedComponents;
        if ([parsedSelector isEqualToString:selectorName]) {
            CKToken *firstToken = selectorComponentTokens.firstObject;
            CKToken *lastToken = argumentTokens.lastObject;
            NSRange range = NSMakeRange(firstToken.range.location, lastToken.range.location - firstToken.range.location + lastToken.range.length);
            XMASObjcMethodCall *methodCall = [[XMASObjcMethodCall alloc] initWithSelectorComponents:selectorComponents
                                                                                          arguments:argumentStrings
                                                                                           filePath:filePath
                                                                                              range:range];
            [methodCalls addObject:methodCall];
        }
    }

    return methodCalls;
}

#pragma mark - Private

- (BOOL)isEndOfMethodCallToken:(CKToken *)token {
    BOOL isPunctuation = token.kind == CKTokenKindPunctuation;
    BOOL isClosingSquareBracket = [token.spelling isEqualToString:@"]"];
    BOOL isObjcMessageExpr = token.cursor.kind == CKCursorKindObjCMessageExpr ||
                             token.cursor.kind == CKCursorKindDeclStmt;
    return isPunctuation && isClosingSquareBracket && isObjcMessageExpr;
}

- (BOOL)isSelectorComponentToken:(CKToken *)token {
    // does this need to check if the following token is a colon?
    return token.kind == CKTokenKindIdentifier &&
            (token.cursor.kind == CKCursorKindObjCMessageExpr || token.cursor.kind == CKCursorKindDeclStmt);
}

- (BOOL)isStartOfMethodCallExpression:(CKToken *)token {
    if (token.cursor.kind == CKCursorKindObjCMessageExpr) {
        return YES;
    }
    if (token.cursor.kind == CKCursorKindDeclStmt && [token.spelling isEqualToString:@"["]) {
        return YES;
    }

    return NO;
}

@end

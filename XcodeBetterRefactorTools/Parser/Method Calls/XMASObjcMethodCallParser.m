#import "XMASObjcMethodCallparser.h"
#import <ClangKit/ClangKit.h>
#import <ClangKit/CKCursor.h>
#import "XMASObjcMethodCall.h"

@interface XMASObjcMethodCallParser ()
@property (nonatomic) NSArray *matchingCallExpressions;
@property (nonatomic) NSString *selectorToMatch;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSArray *tokens;
@end

@implementation XMASObjcMethodCallParser

// ^dispatch_once in -(NSArray *)matchingCallExpressions
// -matchingCallExpressions becomes recursive
// do a first pass to get ALL the call expressions (test this separately)
// foreach call expression, get the target, selector components, arguments, range and build it all up
// then filter on call expressions matching the selector
// (can be more intelligent here and stop when selector components no longer matches the one desired)

- (instancetype)initWithSelectorToMatch:(NSString *)selector
                             inFilePath:(NSString *)filePath
                             withTokens:(NSArray *)tokens {
    if (self = [super init]) {
        self.selectorToMatch = selector;
        self.filePath = filePath;
        self.tokens = tokens;
    }

    return self;
}

#pragma mark - Public

- (NSArray *)matchingCallExpressions {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.matchingCallExpressions = [self parseMatchingCallExpressions];
    });

    return _matchingCallExpressions;
}

#pragma mark - Private

- (NSArray *)parseMatchingCallExpressions {
    NSMutableArray *methodCalls = [[NSMutableArray alloc] init];
    NSUInteger count = self.tokens.count;

    for (NSUInteger i = 0; i < count; ++i) {
        CKToken *token = self.tokens[i];
        NSMutableArray *selectorComponentTokens = [[NSMutableArray alloc] init];
        NSMutableArray *argumentStrings = [[NSMutableArray alloc] init];
        NSMutableArray *argumentTokens = [[NSMutableArray alloc] init];

        if (![self isStartOfMethodCallExpression:token]) {
            continue;
        }

        while ([token.spelling isEqualToString:@"["] && token.kind == CKTokenKindPunctuation) {
            ++i;
            if (i >= self.tokens.count) {
                break;
            }

            token = self.tokens[i];
        }
        --i;

        NSInteger indexSelectorStartsAt = [self indexFollowingCallExpressionTarget:i fromTokens:self.tokens];
        NSArray *targetTokens = [self.tokens subarrayWithRange:NSMakeRange(i, indexSelectorStartsAt - i)];
        i = indexSelectorStartsAt;

        CKToken *matchingCloseToken = [self matchingClosingTokenForCallExpressionAtIndex:i fromTokens:self.tokens];
        for (; i < count; ++i) {
            token = self.tokens[i];
            if (token == matchingCloseToken) {
                break;
            }
            if (![self isSelectorComponentToken:token]) {
                continue;
            }

            [selectorComponentTokens addObject:token];

            i++;
            NSMutableArray *currentArgumentTokens = [[NSMutableArray alloc] init];
            for (; i < count; ++i) {
                token = self.tokens[i];
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
        if ([parsedSelector isEqualToString:self.selectorToMatch]) {
            CKToken *firstToken = selectorComponentTokens.firstObject;
            CKToken *lastToken = argumentTokens.lastObject;
            NSString *targetString = [self stringFromTargetTokens:targetTokens];
            NSRange range = NSMakeRange(firstToken.range.location, lastToken.range.location - firstToken.range.location + lastToken.range.length);
            XMASObjcMethodCall *methodCall = [[XMASObjcMethodCall alloc] initWithSelectorComponents:selectorComponents
                                                                                       columnNumber:firstToken.column
                                                                                         lineNumber:firstToken.line
                                                                                          arguments:argumentStrings
                                                                                           filePath:self.filePath
                                                                                             target:targetString
                                                                                              range:range];
            [methodCalls addObject:methodCall];
        }
    }

    return methodCalls;
}

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

- (CKToken *)matchingClosingTokenForCallExpressionAtIndex:(NSInteger)index
                                               fromTokens:(NSArray *)tokens {
    NSInteger countOfOpenBrackets = 1;
    for (; index < tokens.count; ++index) {
        CKToken *token = tokens[index];
        if ([token.spelling isEqualToString:@"["]) {
            ++countOfOpenBrackets;
        } else if ([token.spelling isEqualToString:@"]"]) {
            --countOfOpenBrackets;
        }

        if (countOfOpenBrackets == 0) {
            return tokens[index];
        }
    }

    return nil;
}

- (NSInteger)indexFollowingCallExpressionTarget:(NSInteger)index fromTokens:(NSArray *)tokens {
    for (NSInteger i = index; i < tokens.count; ++i) {
        CKToken *token = tokens[i];
        CKToken *nextToken = [self safeNextTokenFollowingIndex:i fromTokens:tokens];

        BOOL isIdent = token.kind == CKTokenKindIdentifier;
        BOOL isFollowedByPunctuation = nextToken.kind == CKTokenKindPunctuation;

        // FIXME :: add "]" to below check once we support proper recursive call expressions
        BOOL isEndOfSelectorComponent = [nextToken.spelling isEqualToString:@":"];
        if (isIdent && isFollowedByPunctuation && isEndOfSelectorComponent) {
            return i;
        }
    }

    return tokens.count - 1;
}

- (CKToken *)safeNextTokenFollowingIndex:(NSInteger)index fromTokens:(NSArray *)tokens {
    if (index >= tokens.count) {
        return nil;
    }

    return tokens[index+1];
}

- (NSString *)stringFromTargetTokens:(NSArray *)tokens {
    NSMutableArray *paddedTokens = [[NSMutableArray alloc] initWithCapacity:tokens.count];

    CKToken *token;
    CKToken *previousToken = tokens.firstObject;
    [paddedTokens addObject:previousToken.spelling];

    for (NSInteger index = 1; index < tokens.count; ++index) {
        token = tokens[index];

        if (token.range.location > previousToken.range.location + previousToken.spelling.length) {
            [paddedTokens addObject:[@" " stringByAppendingString:token.spelling]];
        } else {
            [paddedTokens addObject:token.spelling];
        }

        previousToken = token;
    }

    return [paddedTokens componentsJoinedByString:@""];
}

@end

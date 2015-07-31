#import "XMASObjcMethodCallparser.h"
#import <ClangKit/ClangKit.h>
#import <ClangKit/CKCursor.h>
#import "XMASObjcMethodCall.h"
#import "XMASObjcCallExpressionTokenFilter.h"

@interface XMASObjcMethodCallParser ()

@property (nonatomic) XMASObjcCallExpressionTokenFilter *callExpressionTokenFilter;

@property (nonatomic) NSString *selectorToMatch;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSArray *tokens;

@end

@implementation XMASObjcMethodCallParser

- (instancetype)initWithCallExpressionTokenFilter:(XMASObjcCallExpressionTokenFilter *)callExpressionTokenFilter {
    if (self = [super init]) {
        self.callExpressionTokenFilter = callExpressionTokenFilter;
    }

    return self;
}

- (void)setupWithSelectorToMatch:(NSString *)selector
                        filePath:(NSString *)filePath
                       andTokens:(NSArray *)tokens {
    self.selectorToMatch = selector;
    self.filePath = filePath;
    self.tokens = tokens;
}

#pragma mark - Public

- (NSArray *)matchingCallExpressions {
    NSLog(@"================> finding call expressions in %@", self.filePath.lastPathComponent);

    NSSet *callExpressionRanges = [self.callExpressionTokenFilter parseCallExpressionRangesFromTokens:self.tokens];

    NSLog(@"================> %@", self.tokens);

    return [self filterMatchingCallExpressionsFromTokensInRanges:callExpressionRanges];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

- (NSArray *)filterMatchingCallExpressionsFromTokensInRanges:(NSSet *)callExpressionRangeSet {
    NSLog(@"================> found %lu call expressions in %@", callExpressionRangeSet.count, self.filePath.lastPathComponent);

    NSMutableArray *matchingCallExpressions = [[NSMutableArray alloc] init];
    for (NSValue *value in callExpressionRangeSet) {
        NSRange callExprRange = [value rangeValue];
        NSArray *callExprTokens = [self.tokens subarrayWithRange:callExprRange];

        NSLog(@"================> ");
        NSLog(@"================> ");
        NSLog(@"================> tokens between (%lu, %lu) in %@", callExprRange.location, callExprRange.location + callExprRange.length, self.filePath.lastPathComponent);
        NSLog(@"================> %@", callExprTokens);

        for (NSUInteger index = 1; index < callExprTokens.count; ++index) {
            NSMutableArray *selectorComponentTokens = [[NSMutableArray alloc] init];
            NSMutableArray *argumentStrings = [[NSMutableArray alloc] init];
            NSMutableArray *argumentTokens = [[NSMutableArray alloc] init];

            NSUInteger indexSelectorStartsAt = [self indexFollowingCallExpressionTarget:index fromTokens:callExprTokens];
            NSArray *targetTokens = [callExprTokens subarrayWithRange:NSMakeRange(index, indexSelectorStartsAt - index)];
            index = indexSelectorStartsAt;

            CKToken *matchingCloseToken = [self matchingClosingTokenForCallExpressionAtIndex:index fromTokens:callExprTokens];
            CKToken *token = callExprTokens[index];

            while ([self isSelectorComponentToken:token]) {
                [selectorComponentTokens addObject:token];

                token = [self safeNextTokenFollowingIndex:index fromTokens:callExprTokens];
                index++;

                if ([token.spelling isEqualToString:@":"] && token.kind == CKTokenKindPunctuation) {
                    token = [self safeNextTokenFollowingIndex:index fromTokens:callExprTokens];
                    index++;
                }

                // read all of the arguments for the call expression, if any
                NSMutableArray *currentArgumentTokens = [[NSMutableArray alloc] init];

                if ([self isStartOfMethodCallExpression:token]) {
                    NSUInteger indexOfClosingBracket = [self indexOfMatchingClosingTokenForCallExpressionAtIndex:index fromTokens:callExprTokens];
                    NSArray *callExpressionArgumentTokens = [callExprTokens subarrayWithRange:NSMakeRange(index, indexOfClosingBracket - index)];

                    index = indexOfClosingBracket;

                    // FIXME: this assumes arguments have no whitespace?
                    [argumentStrings addObject:[callExpressionArgumentTokens componentsJoinedByString:@""]];
                    [argumentTokens addObject:callExpressionArgumentTokens];
                } else {
                    while (token && !(token == matchingCloseToken)) {
                        CKToken *nextToken = [self safeNextTokenFollowingIndex:index fromTokens:callExprTokens];
                        BOOL nextTokenIsValidAfterSelectorComponent = [self isTokenValidToFollowSelectorComponent:nextToken];
                        if ([self isSelectorComponentToken:token] && nextTokenIsValidAfterSelectorComponent) {
                            NSArray *currentArgumentPieces = [currentArgumentTokens valueForKey:@"spelling"];

                            // FIXME: this assumes arguments have no whitespace?
                            [argumentStrings addObject:[currentArgumentPieces componentsJoinedByString:@""]];
                            [argumentTokens addObject:currentArgumentTokens];
                            [currentArgumentTokens removeAllObjects];

                            --index;
                            token = callExprTokens[index];
                            break;
                        }

                        [currentArgumentTokens addObject:token];

                        token = [self safeNextTokenFollowingIndex:index fromTokens:callExprTokens];
                        index++;
                    }

                    if (currentArgumentTokens.count > 0) {
                        NSArray *currentArgumentPieces = [currentArgumentTokens valueForKey:@"spelling"];
                        // FIXME: this assumes arguments have no whitespace?
                        [argumentStrings addObject:[currentArgumentPieces componentsJoinedByString:@""]];
                        [argumentTokens addObject:currentArgumentTokens];
                    }
                }

                token = [self safeNextTokenFollowingIndex:index fromTokens:callExprTokens];
                ++index;
            }

            NSArray *selectorComponents = [selectorComponentTokens valueForKey:@"spelling"];
            NSString *joinedComponents = [selectorComponents componentsJoinedByString:@":"];
            NSString *parsedSelector = argumentTokens.count > 0 ? [joinedComponents stringByAppendingString:@":"] : joinedComponents;
            if ([parsedSelector isEqualToString:self.selectorToMatch]) {
                CKToken *firstSelectorToken = selectorComponentTokens.firstObject;
                CKToken *firstToken = callExprTokens.firstObject;
                CKToken *lastToken = callExprTokens.lastObject;
                NSString *targetString = [self stringFromTargetTokens:targetTokens];
                NSRange range = NSMakeRange(firstToken.range.location, lastToken.range.location - firstToken.range.location + lastToken.range.length);
                XMASObjcMethodCall *methodCall = [[XMASObjcMethodCall alloc] initWithSelectorComponents:selectorComponents
                                                                                           columnNumber:firstSelectorToken.column
                                                                                             lineNumber:firstSelectorToken.line
                                                                                              arguments:argumentStrings
                                                                                               filePath:self.filePath
                                                                                                 target:targetString
                                                                                                  range:range];
                [matchingCallExpressions addObject:methodCall];
            }
        }
    }

    return matchingCallExpressions;
}

- (BOOL)isTokenValidToFollowSelectorComponent:(CKToken *)token {
    BOOL isPunctuation = token.kind == CKTokenKindPunctuation;

    BOOL isClosingSquareBracket = [token.spelling isEqualToString:@"]"];
    BOOL isNamedArgumentColon = [token.spelling isEqualToString:@":"];

    BOOL isObjcMessageExpr = token.cursor.kind == CKCursorKindObjCMessageExpr ||
                             token.cursor.kind == CKCursorKindDeclStmt;
    return isPunctuation && (isClosingSquareBracket || isNamedArgumentColon) && isObjcMessageExpr;
}

- (BOOL)isSelectorComponentToken:(CKToken *)token {
    // does this need to check if the following token is a colon? or ]?
    return token.kind == CKTokenKindIdentifier &&
            (token.cursor.kind == CKCursorKindObjCMessageExpr || token.cursor.kind == CKCursorKindDeclStmt);
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

// FIXME : some of these can probably just be C-funcs
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

- (CKToken *)matchingClosingTokenForCallExpressionAtIndex:(NSUInteger)index
                                               fromTokens:(NSArray *)tokens {
    NSUInteger countOfOpenBrackets = 1;
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

- (NSUInteger)indexFollowingCallExpressionTarget:(NSUInteger)index fromTokens:(NSArray *)tokens {
    for (NSUInteger i = index; i < tokens.count; ++i) {
        CKToken *token = tokens[i];
        CKToken *nextToken = [self safeNextTokenFollowingIndex:i fromTokens:tokens];

        BOOL isIdent = token.kind == CKTokenKindIdentifier;
        BOOL isFollowedByPunctuation = nextToken.kind == CKTokenKindPunctuation;
        BOOL isEndOfSelectorComponent = [nextToken.spelling isEqualToString:@":"];

        if (isIdent && isFollowedByPunctuation && isEndOfSelectorComponent) {
            return i;
        }
    }

    return tokens.count - 1;
}

- (CKToken *)safeNextTokenFollowingIndex:(NSUInteger)index fromTokens:(NSArray *)tokens {
    if (index + 1 >= tokens.count) {
        return nil;
    }

    return tokens[index+1];
}

- (NSString *)stringFromTargetTokens:(NSArray *)tokens {
    NSMutableArray *paddedTokens = [[NSMutableArray alloc] initWithCapacity:tokens.count];

    CKToken *token;
    CKToken *previousToken = tokens.firstObject;
    [paddedTokens addObject:previousToken.spelling];

    for (NSUInteger index = 1; index < tokens.count; ++index) {
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

#import "XMASObjcSelector.h"
#import "XMASObjcSelectorParameter.h"

@interface XMASObjcSelector ()
@property (nonatomic) NSArray *selectorComponents;
@property (nonatomic) NSArray *parameters;
@end

@implementation XMASObjcSelector

- (instancetype)initWithTokens:(NSArray *)tokens {
    if (self = [super init]) {
        [self parseSelectorComponentsFromTokens:tokens];
    }

    return self;
}

- (NSString *)selectorString {
    if (self.parameters.count == 0) {
        return self.selectorComponents.firstObject;
    }
    else {
        return [[self.selectorComponents componentsJoinedByString:@":"] stringByAppendingString:@":"];
    }
}

#pragma mark - Private

- (void)parseSelectorComponentsFromTokens:(NSArray *)tokens {
    NSMutableArray *selectorComponents = [NSMutableArray array];
    NSMutableArray *parameters = [NSMutableArray array];

    for (NSUInteger i = 0; i < tokens.count; ++i) {
        CKToken *token = tokens[i];
        if (token.kind == CKTokenKindPunctuation && [token.spelling isEqualToString:@"("]) {
            NSString *paramType = [tokens[++i] spelling];
            CKToken *followingToken = tokens[i+1];
            if (followingToken.kind == CKTokenKindPunctuation && [followingToken.spelling isEqualToString:@"*"]) {
                paramType = [paramType stringByAppendingString:@" *"];
                ++i;
            }

            // keep reading until we are past the declaration
            BOOL parsingParam = YES;
            for (CKToken *nextToken = tokens[++i]; parsingParam && i < tokens.count; nextToken = tokens[++i]) {
                BOOL isPunctuation = nextToken.kind == CKTokenKindPunctuation;
                BOOL isClosingParen = [nextToken.spelling isEqualToString:@")"];
                if (isPunctuation && isClosingParen) {
                    parsingParam = NO;
                }
            }

            CKToken *variableNameToken = tokens[i];
            XMASObjcSelectorParameter *param = [[XMASObjcSelectorParameter alloc] initWithType:paramType
                                                                                     localName:variableNameToken.spelling];
            [parameters addObject:param];
            continue;
        }

        if (token.kind == CKTokenKindIdentifier) {
            [selectorComponents addObject:token.spelling];
        }
    }

    self.selectorComponents = selectorComponents;
    self.parameters = parameters;
}

@end

#import "XMASObjcSelector.h"

@interface XMASObjcSelector ()
@property (nonatomic) NSArray *selectorPieces;
@property (nonatomic) NSArray *parameters;
@end

@implementation XMASObjcSelector

- (instancetype)initWithTokens:(NSArray *)tokens {
    if (self = [super init]) {
        [self parseSelectorPiecesFromTokens:tokens];
    }

    return self;
}

- (NSString *)selectorString {
    if (self.parameters.count == 0) {
        return self.selectorPieces.firstObject;
    }
    else {
        return [[self.selectorPieces componentsJoinedByString:@":"] stringByAppendingString:@":"];
    }
}

#pragma mark - Private

- (void)parseSelectorPiecesFromTokens:(NSArray *)tokens {
    NSMutableArray *selectorPieces = [NSMutableArray array];
    NSMutableArray *parameters = [NSMutableArray array];

    BOOL parsingParam = NO;
    for (CKToken *token in tokens) {
        if (token.kind == CKTokenKindPunctuation) {
            if ([token.spelling isEqualToString:@"("]) {
                parsingParam = YES;
                continue;
            } else if ([token.spelling isEqualToString:@")"]) {
                parsingParam = NO;
                continue;
            }
        }

        if (parsingParam) {
            [parameters addObject:@""];
            continue;
        }

        if (token.kind == CKTokenKindIdentifier) {
            [selectorPieces addObject:token.spelling];
        }
    }

    self.selectorPieces = selectorPieces;
    self.parameters = parameters;
}

@end

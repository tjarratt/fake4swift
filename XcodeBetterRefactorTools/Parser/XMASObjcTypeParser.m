#import "XMASObjcTypeParser.h"
#import <ClangKit/ClangKit.h>

@implementation XMASObjcTypeParser

- (NSString *)parseTypeFromTokens:(NSArray *)tokens {
    NSMutableArray *typeIdentifierPieces = [NSMutableArray array];

    for (CKToken *token in tokens) {
        if (token.kind == CKTokenKindIdentifier) {
            [typeIdentifierPieces addObject:token.spelling];
        }
        if (token.kind == CKTokenKindPunctuation && [token.spelling isEqualToString:@"*"]) {
            [typeIdentifierPieces addObject:token.spelling];
        }
        if (token.kind == CKTokenKindKeyword && [token.spelling isEqualToString:@"void"]) {
            [typeIdentifierPieces addObject:token.spelling];
        }
    }

    return [typeIdentifierPieces componentsJoinedByString:@" "];
}

@end

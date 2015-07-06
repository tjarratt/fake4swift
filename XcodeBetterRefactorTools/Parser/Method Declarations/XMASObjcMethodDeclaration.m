#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XMASObjcTypeParser.h"
#import "XMASComponentSwapper.h"

@interface XMASObjcMethodDeclaration ()

@property (nonatomic) NSArray *selectorComponents;
@property (nonatomic) NSArray *parameters;
@property (nonatomic) NSString *returnType;
@property (nonatomic, assign) NSRange range;
@property (nonatomic) XMASComponentSwapper *componentSwapper;

@end

@implementation XMASObjcMethodDeclaration

- (instancetype)initWithTokens:(NSArray *)tokens {
    if (self = [super init]) {
        [self parseSelectorComponentsFromTokens:tokens];
        NSRange start = [tokens.firstObject range];
        NSRange end = [tokens.lastObject range];
        self.range = NSMakeRange(start.location, end.location + end.length - start.location);
        self.componentSwapper = [[XMASComponentSwapper alloc] init];
    }

    return self;
}

- (instancetype)initWithSelectorComponents:(NSArray *)selectorComponents
                                parameters:(NSArray *)parameters
                                returnType:(NSString *)returnType
                                     range:(NSRange)range
{
    if (self = [super init]) {
        self.selectorComponents = selectorComponents;
        self.parameters = parameters;
        self.returnType = returnType;
        self.range = range;
        self.componentSwapper = [[XMASComponentSwapper alloc] init];
    }

    return self;
}

- (NSArray *)components {
    return self.selectorComponents;
}

- (NSString *)selectorString {
    if (self.parameters.count == 0) {
        return self.selectorComponents.firstObject;
    }
    else {
        return [[self.selectorComponents componentsJoinedByString:@":"] stringByAppendingString:@":"];
    }
}

- (NSString *)returnType {
    return _returnType;
}

- (instancetype)deleteComponentAtIndex:(NSUInteger)index {
    NSMutableArray *components = [self.selectorComponents mutableCopy];
    NSMutableArray *parameters = [self.parameters mutableCopy];
    [components removeObjectAtIndex:index];
    [parameters removeObjectAtIndex:index];

    return [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:components
                                                     parameters:parameters
                                                     returnType:self.returnType
                                                          range:self.range];
}

- (instancetype)insertComponentAtIndex:(NSUInteger)index {
    NSMutableArray *components = [self.selectorComponents mutableCopy];
    NSMutableArray *parameters = [self.parameters mutableCopy];

    XMASObjcMethodDeclarationParameter *newParameter = [[XMASObjcMethodDeclarationParameter alloc] initWithType:@"" localName:@""];
    [components insertObject:@"" atIndex:index];
    [parameters insertObject:newParameter atIndex:index];

    return [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:components
                                                     parameters:parameters
                                                     returnType:self.returnType
                                                          range:self.range];
}

- (instancetype)swapComponentAtIndex:(NSUInteger)index withComponentAtIndex:(NSUInteger)otherIndex {
    NSMutableArray *components = [self.selectorComponents mutableCopy];

    XMASComponentPair *componentPair = [self.componentSwapper swapComponent:components[index]
                                                              withComponent:components[otherIndex]];
    components[index] = componentPair.first;
    components[otherIndex] = componentPair.second;

    NSMutableArray *parameters = [self.parameters mutableCopy];
    [parameters exchangeObjectAtIndex:index withObjectAtIndex:otherIndex];

    return [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:components
                                                     parameters:parameters
                                                     returnType:self.returnType
                                                          range:self.range];
}

- (instancetype)changeSelectorNameAtIndex:(NSUInteger)index to:(NSString *)newType {
    NSMutableArray *components = [[self selectorComponents] mutableCopy];
    components[index] = newType;

    return [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:components
                                                     parameters:self.parameters
                                                     returnType:self.returnType
                                                          range:self.range];
}

- (instancetype)changeParameterTypeAtIndex:(NSUInteger)index to:(NSString *)newType {
    NSMutableArray *newParameters = [[self parameters] mutableCopy];
    XMASObjcMethodDeclarationParameter *newParameter = [[XMASObjcMethodDeclarationParameter alloc] initWithType:newType localName:[self.parameters[index] localName]];
    newParameters[index] = newParameter;

    return [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:self.components
                                                     parameters:newParameters
                                                     returnType:self.returnType
                                                          range:self.range];
}

- (instancetype)changeParameterLocalNameAtIndex:(NSUInteger)index to:(NSString *)newName {
    NSMutableArray *newParameters = [[self parameters] mutableCopy];
    XMASObjcMethodDeclarationParameter *newParameter = [[XMASObjcMethodDeclarationParameter alloc] initWithType:[self.parameters[index] type] localName:newName];
    newParameters[index] = newParameter;

    return [[XMASObjcMethodDeclaration alloc] initWithSelectorComponents:self.components
                                                     parameters:newParameters
                                                     returnType:self.returnType
                                                          range:self.range];
}



#pragma mark - Private

- (void)parseSelectorComponentsFromTokens:(NSArray *)tokens {
    NSMutableArray *selectorComponents = [NSMutableArray array];
    NSMutableArray *parameters = [NSMutableArray array];

    NSArray *returnTypeTokens = [NSMutableArray array];
    XMASObjcTypeParser *typeParser = [[XMASObjcTypeParser alloc] init];
    NSUInteger lastTokenParsed = 0;
    for (NSUInteger i = 0; i < tokens.count; ++i) {
        CKToken *token = tokens[i];
        if (token.kind == CKTokenKindPunctuation && [token.spelling isEqualToString:@")"]) {
            returnTypeTokens = [tokens subarrayWithRange:NSMakeRange(0, i)];
            lastTokenParsed = i;
            break;
        }
    }
    self.returnType = [typeParser parseTypeFromTokens:returnTypeTokens];

    for (NSUInteger i = lastTokenParsed; i < tokens.count; ++i) {
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
            XMASObjcMethodDeclarationParameter *param = [[XMASObjcMethodDeclarationParameter alloc] initWithType:paramType
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

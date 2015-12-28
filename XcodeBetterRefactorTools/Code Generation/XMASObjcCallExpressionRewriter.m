@import BetterRefactorToolsKit;

#import "XMASObjcCallExpressionRewriter.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodCallParser.h"
#import "XcodeInterfaces.h"
#import "XMASObjcMethodCall.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XMASObjcCallExpressionStringWriter.h"
#import "XMASTokenizer.h"

@interface XMASObjcCallExpressionRewriter ()
@property (nonatomic) id<XMASAlerter> alerter;
@property (nonatomic) XMASTokenizer *tokenizer;
@property (nonatomic) XMASObjcMethodCallParser *methodCallParser;
@property (nonatomic) XMASObjcCallExpressionStringWriter *callExpressionStringWriter;
@end

@implementation XMASObjcCallExpressionRewriter

- (instancetype)initWithAlerter:(id<XMASAlerter>)alerter
                      tokenizer:(XMASTokenizer *)tokenizer
           callExpressionParser:(XMASObjcMethodCallParser *)callExpressionParser
     callExpressionStringWriter:(XMASObjcCallExpressionStringWriter *)callExpressionStringWriter {
    if (self = [super init]) {
        self.alerter = alerter;
        self.tokenizer = tokenizer;
        self.methodCallParser = callExpressionParser;
        self.callExpressionStringWriter = callExpressionStringWriter;
    }

    return self;
}

- (void)changeCallsite:(XC(IDEIndexSymbol))callsite
            fromMethod:(XMASObjcMethodDeclaration *)oldSelector
           toNewMethod:(XMASObjcMethodDeclaration *)newSelector {

    NSArray *tokens = [self.tokenizer tokensForFilePath:callsite.file.pathString];
    [self.methodCallParser setupWithSelectorToMatch:oldSelector.selectorString
                                           filePath:callsite.file.pathString
                                          andTokens:tokens];

    XMASObjcMethodCall *callExpressionToRewrite;
    NSArray *callExpressionsMatchingSelector = [self.methodCallParser matchingCallExpressions];

    for (XMASObjcMethodCall *callExpression in callExpressionsMatchingSelector) {
        BOOL matchingLineNumber = callExpression.lineNumber == callsite.lineNumber;
        BOOL matchingColumnNumber = callExpression.columnNumber == callsite.column;
        if (matchingLineNumber && matchingColumnNumber) {
            callExpressionToRewrite = callExpression;
            break;
        }
    }

    if (!callExpressionToRewrite) {
        NSString *fileName = callsite.file.pathString.lastPathComponent;
        NSString *sadMessage = [NSString stringWithFormat:@"Aww shucks. Couldn't find '%@' at line %lu column %lu in %@", oldSelector.selectorString, callsite.lineNumber, callsite.column, fileName];
        [self.alerter flashMessage:sadMessage withLogging:YES];
        return;
    }

    NSMutableArray *newArguments = [[NSMutableArray alloc] initWithCapacity:newSelector.parameters.count];
    for (NSUInteger index = 0; index < newSelector.parameters.count; ++index) {
        [newArguments insertObject:[NSNull null] atIndex:index];

        NSString *selectorComponentName = newSelector.components[index];
        if ([oldSelector.components containsObject:selectorComponentName]) {
            NSUInteger indexOfSelectorComponent = [oldSelector.components indexOfObject:selectorComponentName];
            NSString *argumentForSelectorComponent = callExpressionToRewrite.arguments[indexOfSelectorComponent];
            newArguments[index] = argumentForSelectorComponent;
        }
    }

    NSNull *null = [NSNull null];
    for (NSUInteger index = 0; index < newSelector.parameters.count; ++index) {
        if (newArguments[index] != null) {
            continue;
        }

        XMASObjcMethodDeclarationParameter *newParameter = newSelector.parameters[index];
        NSPredicate *matchingTypePredicate = [NSPredicate predicateWithBlock:^BOOL(XMASObjcMethodDeclarationParameter *param, NSDictionary *bindings) {
            return [param.type isEqualToString:newParameter.type];
        }];
        NSArray *matchingOldParameters = [oldSelector.parameters filteredArrayUsingPredicate:matchingTypePredicate];
        NSArray *matchingNewParameters = [newSelector.parameters filteredArrayUsingPredicate:matchingTypePredicate];
        BOOL presentInOldSelector = matchingOldParameters.count == 1;
        BOOL onlyOneParamOfType = matchingNewParameters.count == 1;

        if (presentInOldSelector && onlyOneParamOfType) {
            NSUInteger indexOfParameter = [oldSelector.parameters indexOfObject:matchingNewParameters.firstObject];
            NSString *argumentForParameter = callExpressionToRewrite.arguments[indexOfParameter];
            newArguments[index] = argumentForParameter;
        }
    }

    for (NSUInteger index = 0; index < newSelector.parameters.count; ++index) {
        if (newArguments[index] != null) {
            continue;
        }

        newArguments[index] = @"nil";
    }

    NSStringEncoding usedEncoding;
    NSString *oldFileContents = [NSString stringWithContentsOfFile:callExpressionToRewrite.filePath
                                                      usedEncoding:&usedEncoding
                                                            error:nil];

    NSString *newCallExpressionString = [self.callExpressionStringWriter callExpression:newSelector
                                                                              forTarget:callExpressionToRewrite.target
                                                                               withArgs:newArguments
                                                                               atColumn:callExpressionToRewrite.columnNumber];
    NSString *refactoredFile = [oldFileContents stringByReplacingCharactersInRange:callExpressionToRewrite.range
                                                                       withString:newCallExpressionString];
    [refactoredFile writeToFile:callExpressionToRewrite.filePath
                     atomically:YES
                       encoding:usedEncoding
                          error:nil];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

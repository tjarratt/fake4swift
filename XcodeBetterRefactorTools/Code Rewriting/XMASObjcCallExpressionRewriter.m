#import "XMASObjcCallExpressionRewriter.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodCallParser.h"
#import <ClangKit/ClangKit.h>
#import "XcodeInterfaces.h"
#import "XMASObjcMethodCall.h"
#import "XMASAlert.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XMASObjcCallExpressionStringWriter.h"

@interface XMASObjcCallExpressionRewriter ()
@property (nonatomic) XMASAlert *alerter;
@property (nonatomic) XMASObjcMethodCallParser *methodCallParser;
@property (nonatomic) XMASObjcCallExpressionStringWriter *callExpressionStringWriter;
@end

@implementation XMASObjcCallExpressionRewriter

- (instancetype)initWithAlerter:(XMASAlert *)alerter
           callExpressionParser:(XMASObjcMethodCallParser *)callExpressionParser
     callExpressionStringWriter:(XMASObjcCallExpressionStringWriter *)callExpressionStringWriter {
    if (self = [super init]) {
        self.alerter = alerter;
        self.methodCallParser = callExpressionParser;
        self.callExpressionStringWriter = callExpressionStringWriter;
    }

    return self;
}

- (void)changeCallsite:(XC(IDEIndexSymbol))callsite
            fromMethod:(XMASObjcMethodDeclaration *)oldSelector
           toNewMethod:(XMASObjcMethodDeclaration *)newSelector {

    // CONSIDER :: should we have a (singleton-provided) object that handles read access to tokens for a given file?
    // (this would be a good use case for a monostate, quite possibly)
    NSString *fileContents = [NSString stringWithContentsOfFile:callsite.file.pathString
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    NSArray *tokens = [[CKTranslationUnit translationUnitWithText:fileContents language:CKLanguageObjCPP] tokens];
    [self.methodCallParser setupWithSelectorToMatch:oldSelector.selectorString
                                           filePath:callsite.file.pathString
                                          andTokens:tokens];

    NSArray *callExpressionsMatchingSelector = [self.methodCallParser matchingCallExpressions];
    NSLog(@"================> found %lu call exprs matching %@ in %@", callExpressionsMatchingSelector.count, oldSelector.selectorString, callsite.file.pathString);

    XMASObjcMethodCall *callExpressionToRewrite;
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

    NSString *oldFileContents = [NSString stringWithContentsOfFile:callExpressionToRewrite.filePath
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil];

    NSString *newCallExpressionString = [self.callExpressionStringWriter callExpression:newSelector
                                                                              forTarget:callExpressionToRewrite.target
                                                                               withArgs:newArguments
                                                                               atColumn:callExpressionToRewrite.columnNumber];
    NSString *refactoredFile = [oldFileContents stringByReplacingCharactersInRange:callExpressionToRewrite.range
                                                                       withString:newCallExpressionString];
    [refactoredFile writeToFile:callExpressionToRewrite.filePath
                     atomically:YES
                       encoding:NSUTF8StringEncoding
                          error:nil];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

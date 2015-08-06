#import "XMASObjcMethodDeclarationStringWriter.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XMASObjcMethodDeclaration.h"

@implementation XMASObjcMethodDeclarationStringWriter

- (NSString *)formatInstanceMethodDeclaration:(XMASObjcMethodDeclaration *)callExpression {

    NSMutableArray *pieces = [[NSMutableArray alloc] initWithCapacity:callExpression.components.count];

    NSString *firstSelectorComponent = callExpression.components.firstObject;
    XMASObjcMethodDeclarationParameter *firstParam = callExpression.parameters.firstObject;
    NSString *firstParameterDeclaration = [self formatParameterDeclarationString:firstParam];
    [pieces addObject:[NSString stringWithFormat:@"%@%@", firstSelectorComponent, firstParameterDeclaration]];

    NSUInteger charactersBeforeFirstColon = 2 + 2 + callExpression.returnType.length + firstSelectorComponent.length;
    for (NSUInteger i = 1; i < callExpression.components.count; ++i) {
        NSString *componentName = callExpression.components[i];
        XMASObjcMethodDeclarationParameter *param = callExpression.parameters[i];

        NSUInteger paddingNeeded = MAX(charactersBeforeFirstColon - componentName.length, 0);
        NSString *padding = [@"\n" stringByPaddingToLength:1 + paddingNeeded withString:@" " startingAtIndex:0];
        NSString *parameterDeclaration = [self formatParameterDeclarationString:param];

        [pieces addObject:[NSString stringWithFormat:@"%@%@%@", padding, componentName, parameterDeclaration]];
    }

    return [NSString stringWithFormat:@"- (%@)%@", callExpression.returnType, [pieces componentsJoinedByString:@""]];
}

#pragma mark - Private

- (NSString *)formatParameterDeclarationString:(XMASObjcMethodDeclarationParameter *)param {
    NSString *parameterDeclaration = @"";

    BOOL validParameterType = param.type && ![param.type isEqualToString:@""];
    BOOL validParameterName = param.localName && ![param.localName isEqualToString:@""];
    if (validParameterType || validParameterName) {
        NSString *type = param.type ? param.type : @"";
        NSString *localName = param.localName ? param.localName : @"";
        parameterDeclaration = [NSString stringWithFormat:@":(%@)%@", type, localName];
    }

    return parameterDeclaration;
}

@end

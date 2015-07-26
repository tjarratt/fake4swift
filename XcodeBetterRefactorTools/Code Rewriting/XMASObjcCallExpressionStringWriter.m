#import "XMASObjcCallExpressionStringWriter.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationParameter.h"

@implementation XMASObjcCallExpressionStringWriter

- (NSString *)callExpression:(XMASObjcMethodDeclaration *)callExpression
                   forTarget:(NSString *)target
                    withArgs:(NSArray *)args
                    atColumn:(NSUInteger)column {

    NSString *joinedNamedParams;
    if (args.count == 0) {
        joinedNamedParams = callExpression.components.firstObject;
    } else {
        NSMutableArray *namedParams = [[NSMutableArray alloc] initWithCapacity:args.count];

        NSString *firstSelectorComponent = callExpression.components.firstObject;
        NSString *firstArgument = args.firstObject;
        [namedParams addObject:[NSString stringWithFormat:@"%@:%@", firstSelectorComponent, firstArgument]];

        NSUInteger charactersBeforeFirstColon = column + firstSelectorComponent.length - 1;

        for (NSUInteger index = 1; index < args.count; ++index) {
            NSString *selectorComponent = callExpression.components[index];
            NSString *argument = args[index];

            NSUInteger paddingNeeded = MAX(charactersBeforeFirstColon - selectorComponent.length, 0);
            NSString *padding = [@"\n" stringByPaddingToLength:1 + paddingNeeded withString:@" " startingAtIndex:0];
            [namedParams addObject:[NSString stringWithFormat:@"%@%@:%@", padding, selectorComponent, argument]];
        }

        joinedNamedParams = [namedParams componentsJoinedByString:@""];
    }

    return [NSString stringWithFormat:@"[%@ %@]", target, joinedNamedParams];
}

- (NSString *)formatInstanceMethodDeclaration:(XMASObjcMethodDeclaration *)callExpression {

    NSMutableArray *pieces = [[NSMutableArray alloc] initWithCapacity:callExpression.components.count];

    NSString *firstSelectorComponent = callExpression.components.firstObject;
    XMASObjcMethodDeclarationParameter *firstParam = callExpression.parameters.firstObject;
    [pieces addObject:[NSString stringWithFormat:@"%@:(%@)%@", firstSelectorComponent, firstParam.type, firstParam.localName]];

    NSUInteger charactersBeforeFirstColon = 2 + 2 + callExpression.returnType.length + firstSelectorComponent.length;

    for (NSUInteger i = 1; i < callExpression.components.count; ++i) {
        NSString *componentName = callExpression.components[i];
        XMASObjcMethodDeclarationParameter *param = callExpression.parameters[i];

        NSUInteger paddingNeeded = MAX(charactersBeforeFirstColon - componentName.length, 0);
        NSString *padding = [@"\n" stringByPaddingToLength:1 + paddingNeeded withString:@" " startingAtIndex:0];
        [pieces addObject:[NSString stringWithFormat:@"%@%@:(%@)%@", padding, componentName, param.type, param.localName]];
    }

    return [NSString stringWithFormat:@"- (%@)%@", callExpression.returnType, [pieces componentsJoinedByString:@""]];
}

@end

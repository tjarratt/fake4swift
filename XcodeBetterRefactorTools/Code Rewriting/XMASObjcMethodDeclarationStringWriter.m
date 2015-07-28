#import "XMASObjcMethodDeclarationStringWriter.h"
#import "XMASObjcMethodDeclarationParameter.h"
#import "XMASObjcMethodDeclaration.h"

@implementation XMASObjcMethodDeclarationStringWriter

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

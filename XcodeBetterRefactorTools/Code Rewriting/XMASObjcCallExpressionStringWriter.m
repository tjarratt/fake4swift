#import "XMASObjcCallExpressionStringWriter.h"
#import "XMASObjcMethodDeclaration.h"

@implementation XMASObjcCallExpressionStringWriter

- (NSString *)callExpression:(XMASObjcMethodDeclaration *)callExpression
                   forTarget:(NSString *)target
                    withArgs:(NSArray *)args
                    atColumn:(NSInteger)column {

    NSString *joinedNamedParams;
    if (args.count == 0) {
        joinedNamedParams = callExpression.components.firstObject;
    } else {
        NSMutableArray *namedParams = [[NSMutableArray alloc] initWithCapacity:args.count];

        NSString *firstSelectorComponent = callExpression.components.firstObject;
        NSString *firstArgument = args.firstObject;
        [namedParams addObject:[NSString stringWithFormat:@"%@:%@", firstSelectorComponent, firstArgument]];

        NSInteger charactersBeforeFirstColon = column + firstSelectorComponent.length - 1;

        for (NSUInteger index = 1; index < args.count; ++index) {
            NSString *selectorComponent = callExpression.components[index];
            NSString *argument = args[index];

            NSInteger paddingNeeded = MAX(charactersBeforeFirstColon - selectorComponent.length, 0);
            NSString *padding = [@"\n" stringByPaddingToLength:1 + paddingNeeded withString:@" " startingAtIndex:0];
            [namedParams addObject:[NSString stringWithFormat:@"%@%@:%@", padding, selectorComponent, argument]];
        }

        joinedNamedParams = [namedParams componentsJoinedByString:@""];
    }

    return [NSString stringWithFormat:@"[%@ %@]", target, joinedNamedParams];
}

@end

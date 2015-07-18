#import "XMASObjcCallExpressionStringWriter.h"
#import "XMASObjcMethodDeclaration.h"

@implementation XMASObjcCallExpressionStringWriter

- (NSString *)callExpression:(XMASObjcMethodDeclaration *)callExpression
                   forTarget:(NSString *)target
                    withArgs:(NSArray *)args {

    NSString *joinedNamedParams;
    if (args.count == 0) {
        joinedNamedParams = callExpression.components.firstObject;
    } else {
        NSMutableArray *namedParams = [[NSMutableArray alloc] initWithCapacity:args.count];
        for (NSUInteger index = 0; index < args.count; ++index) {
            NSString *selectorComponent = callExpression.components[index];
            NSString *argument = args[index];
            [namedParams addObject:[NSString stringWithFormat:@"%@:%@", selectorComponent, argument]];
        }

        joinedNamedParams = [namedParams componentsJoinedByString:@" "];
    }

    return [NSString stringWithFormat:@"[%@ %@]", target, joinedNamedParams];
}

@end

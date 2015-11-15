#import <Foundation/Foundation.h>

@interface MyObject
- (instancetype)initWithFoo:(Foo *)firstFoo
                     andFoo:(Foo *)secondFoo
                 anotherFoo:(Foo *)thirdFoo
                    moreFoo:(Foo *)fourthFoo;
@end

@interface Foo ()
- (instancetype)myFoo:(NSUInteger)fooNumber;
@end

@interface NestedCallExpressions ()

- (void)example;

@end

@implementation NestedCallExpressions

- (void)exampleWithMessage:(NSString *)message {
    id alertPanel = [[NSClassFromString(@"DVTBezelAlertPanel") alloc] initWithIcon:nil
                                                                           message:message
                                                                      parentWindow:nil
                                                                          duration:2.0];

    id obj = [[MyObject alloc] initWithFoo:[Foo myFoo:1]
                                    andFoo:[Foo myFoo:2]
                                anotherFoo:[Foo myFoo:3]
                                   moreFoo:[Foo myFoo:4]];
}

@end

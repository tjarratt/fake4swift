#import <Foundation/Foundation.h>

@class XMASAlert;
@class XMASObjcMethodDeclarationParser;
@class XMASChangeMethodSignatureControllerProvider;

extern NSString * const noMethodSelected;

@interface XMASRefactorMethodAction : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithEditor:(id)editor
                       alerter:(XMASAlert *)alerter
            controllerProvider:(XMASChangeMethodSignatureControllerProvider *)contollerProvider
              methodDeclParser:(XMASObjcMethodDeclarationParser *)methodDeclParser NS_DESIGNATED_INITIALIZER;

- (void)refactorMethodUnderCursor;


@end

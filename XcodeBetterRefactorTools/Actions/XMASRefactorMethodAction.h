#import <Foundation/Foundation.h>
#import "XMASChangeMethodSignatureController.h"

@class XMASAlert;
@class XMASObjcMethodDeclarationParser;
@class XMASChangeMethodSignatureControllerProvider;

extern NSString * const noMethodSelected;

@interface XMASRefactorMethodAction : NSObject <XMASChangeMethodSignatureControllerDelegate>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithEditor:(id)editor
                       alerter:(XMASAlert *)alerter
            controllerProvider:(XMASChangeMethodSignatureControllerProvider *)contollerProvider
              methodDeclParser:(XMASObjcMethodDeclarationParser *)methodDeclParser NS_DESIGNATED_INITIALIZER;

- (void)refactorMethodUnderCursor;

@property (nonatomic, readonly) XMASChangeMethodSignatureController *controller;


@end

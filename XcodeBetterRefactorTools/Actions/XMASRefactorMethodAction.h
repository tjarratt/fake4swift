#import <Foundation/Foundation.h>
#import "XMASChangeMethodSignatureController.h"

@class XMASAlert;
@class XMASTokenizer;
@class XMASObjcMethodDeclarationParser;
@class XMASChangeMethodSignatureControllerProvider;

extern NSString * const noMethodSelected;

@interface XMASRefactorMethodAction : NSObject <XMASChangeMethodSignatureControllerDelegate>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAlerter:(XMASAlert *)alerter
                      tokenizer:(XMASTokenizer *)tokenizer
             controllerProvider:(XMASChangeMethodSignatureControllerProvider *)contollerProvider
               methodDeclParser:(XMASObjcMethodDeclarationParser *)methodDeclParser NS_DESIGNATED_INITIALIZER;

- (void)setupWithEditor:(id)editor;

- (void)refactorMethodUnderCursor;
- (void)safelyRefactorMethodUnderCursor;

@property (nonatomic, readonly) XMASChangeMethodSignatureController *controller;
@property (nonatomic, readonly) id currentEditor;


@end

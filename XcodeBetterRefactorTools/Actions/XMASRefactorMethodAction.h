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
- (instancetype)initWithAlerter:(id<XMASAlerter>)alerter
                      tokenizer:(XMASTokenizer *)tokenizer
             controllerProvider:(XMASChangeMethodSignatureControllerProvider *)contollerProvider
               methodDeclParser:(XMASObjcMethodDeclarationParser *)methodDeclParser NS_DESIGNATED_INITIALIZER;

- (void)setupWithEditor:(id)editor;

- (void)refactorMethodUnderCursor;
- (void)safelyRefactorMethodUnderCursor;

@property (nonatomic, readonly) id currentEditor;
@property (nonatomic, readonly) id<XMASAlerter> alerter;
@property (nonatomic, readonly) XMASTokenizer *tokenizer;
@property (nonatomic, readonly) XMASObjcMethodDeclarationParser *methodDeclParser;
@property (nonatomic, readonly) XMASChangeMethodSignatureControllerProvider *controllerProvider;

@property (nonatomic, readonly) XMASChangeMethodSignatureController *controller;


@end

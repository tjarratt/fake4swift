#import <Cocoa/Cocoa.h>
#import "XMASObjcMethodDeclaration.h"

@class XMASAlert;
@class XMASObjcMethodDeclaration;
@class XMASWindowProvider;
@class XMASIndexedSymbolRepository;
@class XMASObjcCallExpressionRewriter;
@protocol XMASChangeMethodSignatureControllerDelegate;

@interface XMASChangeMethodSignatureController : NSViewController <NSWindowDelegate, NSTextFieldDelegate>

@property (nonatomic, weak, readonly) NSTableView *tableView;
@property (nonatomic, weak, readonly) NSButton *addComponentButton;
@property (nonatomic, weak, readonly) NSButton *removeComponentButton;
@property (nonatomic, weak, readonly) NSButton *raiseComponentButton;
@property (nonatomic, weak, readonly) NSButton *lowerComponentButton;
@property (nonatomic, weak, readonly) NSButton *cancelButton;
@property (nonatomic, weak, readonly) NSButton *refactorButton;
@property (nonatomic, weak, readonly) NSTextField *previewTextField;

@property (nonatomic, weak, readonly) id <XMASChangeMethodSignatureControllerDelegate> delegate;
@property (nonatomic, readonly) XMASIndexedSymbolRepository *indexedSymbolRepository;
@property (nonatomic, readonly) XMASObjcCallExpressionRewriter *callExpressionRewriter;
@property (nonatomic, readonly) XMASWindowProvider *windowProvider;
@property (nonatomic, readonly) XMASObjcMethodDeclaration *method;
@property (nonatomic, readonly) XMASAlert *alerter;


- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider
                              delegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate
                               alerter:(XMASAlert *)alerter
               indexedSymbolRepository:(XMASIndexedSymbolRepository *)indexedSymbolRepository
                callExpressionRewriter:(XMASObjcCallExpressionRewriter *)objcCallExpressionRewriter NS_DESIGNATED_INITIALIZER;
- (void)refactorMethod:(XMASObjcMethodDeclaration *)method inFile:(NSString *)filePath;

@end

@interface XMASChangeMethodSignatureController (UnavailableInitializers)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
@end

@protocol XMASChangeMethodSignatureControllerDelegate
- (void)controllerWillDisappear:(XMASChangeMethodSignatureController *)controller;
@end
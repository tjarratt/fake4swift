#import <Cocoa/Cocoa.h>
#import "XMASObjcMethodDeclaration.h"

@class XMASAlert;
@class XMASObjcMethodDeclaration;
@class XMASWindowProvider;
@class XMASMethodOccurrencesRepository;
@class XMASObjcCallExpressionRewriter;
@class XMASObjcMethodDeclarationRewriter;
@class XMASObjcMethodDeclarationStringWriter;
@protocol XMASChangeMethodSignatureControllerDelegate;

@interface XMASChangeMethodSignatureController : NSViewController <NSWindowDelegate, NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak, readonly) NSTableView *tableView;
@property (nonatomic, weak, readonly) NSLayoutConstraint *tableviewHeight;
@property (nonatomic, weak, readonly) NSButton *addComponentButton;
@property (nonatomic, weak, readonly) NSButton *removeComponentButton;
@property (nonatomic, weak, readonly) NSButton *raiseComponentButton;
@property (nonatomic, weak, readonly) NSButton *lowerComponentButton;
@property (nonatomic, weak, readonly) NSButton *cancelButton;
@property (nonatomic, weak, readonly) NSButton *refactorButton;
@property (nonatomic, weak, readonly) NSTextField *previewTextField;

@property (nonatomic, weak, readonly) id <XMASChangeMethodSignatureControllerDelegate> delegate;
@property (nonatomic, readonly) XMASMethodOccurrencesRepository *methodOccurrencesRepository;
@property (nonatomic, readonly) XMASObjcMethodDeclarationStringWriter *methodDeclarationStringWriter;
@property (nonatomic, readonly) XMASObjcCallExpressionRewriter *callExpressionRewriter;
@property (nonatomic, readonly) XMASObjcMethodDeclarationRewriter *methodDeclarationRewriter;
@property (nonatomic, readonly) XMASWindowProvider *windowProvider;
@property (nonatomic, readonly) XMASObjcMethodDeclaration *method;
@property (nonatomic, readonly) XMASAlert *alerter;


- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider
                              delegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate
                               alerter:(XMASAlert *)alerter
               methodOccurrencesRepository:(XMASMethodOccurrencesRepository *)methodOccurrencesRepository
                callExpressionRewriter:(XMASObjcCallExpressionRewriter *)objcCallExpressionRewriter
         methodDeclarationStringWriter:(XMASObjcMethodDeclarationStringWriter *)methodDeclarationStringWriter
             methodDeclarationRewriter:(XMASObjcMethodDeclarationRewriter *)methodDeclarationRewriter NS_DESIGNATED_INITIALIZER;

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

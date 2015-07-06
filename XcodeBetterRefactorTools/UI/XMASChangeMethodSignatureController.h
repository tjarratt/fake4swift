#import <Cocoa/Cocoa.h>
#import "XMASObjcMethodDeclaration.h"

@class XMASAlert;
@class XMASObjcMethodDeclaration;
@class XMASWindowProvider;
@class XMASIndexedSymbolRepository;
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
@property (nonatomic, readonly) XMASWindowProvider *windowProvider;
@property (nonatomic, readonly) XMASObjcMethodDeclaration *method;
@property (nonatomic, readonly) XMASAlert *alerter;


- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider
                              delegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate
                               alerter:(XMASAlert *)alerter
               indexedSymbolRepository:(XMASIndexedSymbolRepository *)indexedSymbolRepository;
- (void)refactorMethod:(XMASObjcMethodDeclaration *)method inFile:(NSString *)filePath;

@end

@protocol XMASChangeMethodSignatureControllerDelegate
- (void)controllerWillDisappear:(XMASChangeMethodSignatureController *)controller;
@end

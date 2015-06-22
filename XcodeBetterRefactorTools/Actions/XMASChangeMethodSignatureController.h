#import <Cocoa/Cocoa.h>
#import "XMASObjcSelector.h"

@class XMASWindowProvider;
@protocol XMASChangeMethodSignatureControllerDelegate;

@interface XMASChangeMethodSignatureController : NSViewController <NSWindowDelegate>

@property (nonatomic, weak, readonly) NSTableView *tableView;
@property (nonatomic, weak, readonly) NSButton *addComponentButton;
@property (nonatomic, weak, readonly) NSButton *removeComponentButton;
@property (nonatomic, weak, readonly) NSButton *raiseComponentButton;
@property (nonatomic, weak, readonly) NSButton *lowerComponentButton;
@property (nonatomic, weak, readonly) NSButton *cancelButton;
@property (nonatomic, weak, readonly) NSButton *refactorButton;

@property (nonatomic, weak, readonly) id <XMASChangeMethodSignatureControllerDelegate> delegate;
@property (nonatomic, readonly) XMASWindowProvider *windowProvider;

- (instancetype)initWithWindowProvider:(XMASWindowProvider *)windowProvider
                              delegate:(id<XMASChangeMethodSignatureControllerDelegate>)delegate;
- (void)refactorMethod:(XMASObjcSelector *)method inFile:(NSString *)filePath;

@end

@protocol XMASChangeMethodSignatureControllerDelegate
- (void)controllerWillDisappear:(XMASChangeMethodSignatureController *)controller;
@end

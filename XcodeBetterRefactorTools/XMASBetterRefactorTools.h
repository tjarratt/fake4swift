#import <Cocoa/Cocoa.h>

@class XMASEditMenu;

@interface XMASBetterRefactorTools : NSObject {
    XMASEditMenu *_editMenu;
}

+ (void)pluginDidLoad:(NSBundle *)plugin;
@end

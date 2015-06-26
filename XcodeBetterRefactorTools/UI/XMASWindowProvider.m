#import "XMASWindowProvider.h"

@implementation XMASWindowProvider

- (NSWindow *)provideInstance {
    NSRect screenRect = [[NSScreen mainScreen] frame];
    CGFloat originX = CGRectGetMidX(screenRect);
    CGFloat originY = CGRectGetMidY(screenRect);
    CGFloat height = 200;
    CGFloat width = 600;
    NSRect rect = NSMakeRect(originX - (width / 2.0f), originY - (height / 2.0f), width, height);
    NSUInteger styleMask = NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask;

    return [[NSWindow alloc] initWithContentRect:rect
                                       styleMask:styleMask
                                         backing:NSBackingStoreBuffered
                                           defer:NO];
}

@end

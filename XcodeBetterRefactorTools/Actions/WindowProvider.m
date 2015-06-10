#import "WindowProvider.h"

static NSWindow *window;

@implementation WindowProvider

- (NSWindow *)provideInstance {
    if (!window) {
        NSRect rect = NSMakeRect(0, 0, 0, 0);
        NSUInteger styleMask = NSTitledWindowMask & NSClosableWindowMask;

        window = [[NSWindow alloc] initWithContentRect:rect
                                             styleMask:styleMask
                                               backing:NSBackingStoreBuffered
                                                 defer:NO];
    }

    return window;
}

@end

#import "XMASObjcClassForwardDeclarationWriter.h"

@implementation XMASObjcClassForwardDeclarationWriter

- (NSString *)forwardDeclarationForClassNamed:(NSString *)name {
    return [NSString stringWithFormat:@"@class %@;\n", name];
}

@end

#import "XMASObjcMethodDeclarationRewriter.h"
#import "XMASObjcMethodDeclaration.h"
#import "XMASObjcMethodDeclarationStringWriter.h"

@interface XMASObjcMethodDeclarationRewriter ()
@property (nonatomic) XMASObjcMethodDeclarationStringWriter *methodDeclarationStringWriter;
@end

@implementation XMASObjcMethodDeclarationRewriter

- (instancetype)initWithMethodDeclarationStringWriter:(XMASObjcMethodDeclarationStringWriter *)methodDeclarationStringWriter {
    if (self = [super init]) {
        self.methodDeclarationStringWriter = methodDeclarationStringWriter;
    }

    return self;
}

- (void)changeMethodDeclaration:(XMASObjcMethodDeclaration *)oldMethodDeclaration
                    toNewMethod:(XMASObjcMethodDeclaration *)newMethodDeclaration
                         inFile:(NSString *)filePath {
    NSString *foobarbaz = [self.methodDeclarationStringWriter formatInstanceMethodDeclaration:newMethodDeclaration];

    NSString *oldFileContents = [NSString stringWithContentsOfFile:filePath
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
    NSString *newFileContents = [oldFileContents stringByReplacingCharactersInRange:oldMethodDeclaration.range
                                                                         withString:foobarbaz];
    [newFileContents writeToFile:filePath
                      atomically:YES
                        encoding:NSUTF8StringEncoding
                           error:nil];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

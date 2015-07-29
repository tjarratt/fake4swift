#import <Foundation/Foundation.h>

@interface TempFileHelper : NSObject

+ (NSString *)temporaryFilePathForFixture:(NSString *)fixtureName ofType:(NSString *)type;

@end

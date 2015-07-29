#import "TempFileHelper.h"

@implementation TempFileHelper

+ (NSString *)temporaryFilePathForFixture:(NSString *)fixtureName ofType:(NSString *)fixtureType {
    NSString *pathToFixture = [[NSBundle mainBundle] pathForResource:fixtureName ofType:fixtureType];
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    NSString *temporaryFileName = [NSString stringWithFormat:@"%@-%@.m", fixtureName, uuidStr];
    NSString *tempFixturePath = [NSTemporaryDirectory() stringByAppendingString:temporaryFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager copyItemAtPath:pathToFixture toPath:tempFixturePath error:nil];

    return tempFixturePath;
}

@end

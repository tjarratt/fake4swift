#import "XMASComponentSwapper.h"

@interface XMASComponentPair ()

@property (nonatomic) NSString *first;
@property (nonatomic) NSString *second;

@end

@implementation XMASComponentPair

@end


@implementation XMASComponentSwapper

- (XMASComponentPair *)swapComponent:(NSString *)firstName withComponent:(NSString *)secondName {
    XMASComponentPair *pair = [[XMASComponentPair alloc] init];
    pair.first = secondName;
    pair.second = firstName;


    if ([firstName hasPrefix:@"initWith"]) {
        pair.second = [self downcaseFirstLetterOfString:[firstName substringFromIndex:8]];

        if ([secondName hasPrefix:@"and"]) {
            pair.first = [pair.first substringFromIndex:3];
            pair.second = [@"and" stringByAppendingString:[self upcaseFirstLetterOfString:pair.second]];
        }

        pair.first = [@"initWith" stringByAppendingString:[self upcaseFirstLetterOfString:pair.first]];
    }

    if ([secondName hasPrefix:@"initWith"]) {
        pair.first = [self downcaseFirstLetterOfString:[secondName substringFromIndex:8]];

        if ([firstName hasPrefix:@"and"]) {
            pair.second = [pair.second substringFromIndex:3];
            pair.first = [@"and" stringByAppendingString:[self upcaseFirstLetterOfString:pair.first]];
        }

        pair.second = [@"initWith" stringByAppendingString:[self upcaseFirstLetterOfString:pair.second]];
    }

    return pair;
}

#pragma mark - Private

- (NSString *)upcaseFirstLetterOfString:(NSString *)string {
    return [NSString stringWithFormat:@"%@%@", [[string substringToIndex:1] capitalizedString], [string substringFromIndex:1]];
}

- (NSString *)downcaseFirstLetterOfString:(NSString *)string {
    return [NSString stringWithFormat:@"%@%@", [[string substringToIndex:1] lowercaseString], [string substringFromIndex:1]];
}


@end

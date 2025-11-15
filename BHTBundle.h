#import <Foundation/Foundation.h>

@interface BHTBundle : NSObject
+ (instancetype)sharedBundle;
- (NSString *)localizedStringForKey:(NSString *)key;
- (NSURL *)pathForFile:(NSString *)fileName;
@end

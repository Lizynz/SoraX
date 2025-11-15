#import "BHTBundle.h"

@interface BHTBundle ()
@property (nonatomic, strong) NSBundle *mainBundle;
@end

@implementation BHTBundle

+ (instancetype)sharedBundle {
    static BHTBundle *sharedBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *bundlePath = [NSURL new];
        if ([fileManager fileExistsAtPath:@"/Library/Application Support/SoraX.bundle"]) {
            bundlePath = [NSURL fileURLWithPath:@"/Library/Application Support/SoraX.bundle"];
        } else if ([fileManager fileExistsAtPath:@"/var/jb/Library/Application Support/SoraX/SoraX.bundle"]) {
            bundlePath = [NSURL fileURLWithPath:@"/var/jb/Library/Application Support/SoraX/SoraX.bundle"];
        } else {
            bundlePath = [[NSBundle mainBundle] URLForResource:@"SoraX" withExtension:@"bundle"];
        }
        
        sharedBundle = [[self alloc] initWithBundlePath:bundlePath];
    });
    return sharedBundle;
}

- (instancetype)initWithBundlePath:(NSURL *)bundlePath {
    if (self = [super init]) {
        self.mainBundle = [NSBundle bundleWithPath:[bundlePath path]];
    }
    
    return self;
}

- (NSString *)localizedStringForKey:(NSString *)key {
    return [self.mainBundle localizedStringForKey:key value:key table:nil];
}

- (NSURL *)pathForFile:(NSString *)fileName {
    return [self.mainBundle URLForResource:fileName withExtension:nil];
}

@end

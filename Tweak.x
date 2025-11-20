#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD/MBProgressHUD.h"
#import "BHTBundle.h"
#include <roothide.h>

@interface UIContextMenuInteraction(private)
- (void)_presentMenuAtLocation:(CGPoint)location;
@end

@interface _UIContextMenuStyle : NSObject <NSCopying>
@property(nonatomic) NSInteger preferredLayout;
+ (instancetype)defaultStyle;
@end

static void *CurrentLocalURLKey = &CurrentLocalURLKey;
static void *DownloadTaskKey = &DownloadTaskKey;
static void *CurrentHUDKey = &CurrentHUDKey;

static AVPlayer *findActivePlayerInSubviews(UIView *view) {
    for (UIView *subview in view.subviews) {
        if ([subview.layer isKindOfClass:[AVPlayerLayer class]]) {
            AVPlayerLayer *layer = (AVPlayerLayer *)subview.layer;
            if (layer.player) {
                return layer.player;
            }
        }
        AVPlayer *found = findActivePlayerInSubviews(subview);
        if (found) return found;
    }
    return nil;
}

static void cleanCFNetworkTempFiles() {
    NSString *tempDir = NSTemporaryDirectory();
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempDir error:&error];
    if (error) {
        return;
    }

    for (NSString *file in files) {
        if ([file hasPrefix:@"CFNetworkDownload_"] && [file hasSuffix:@".tmp"]) {
            NSString *filePath = [tempDir stringByAppendingPathComponent:file];
            NSError *removeError = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError];
        }
    }
}

static NSString *cleanHTTPURLFromString(NSString *rawString) {
    NSRange range = [rawString rangeOfString:@"http"];
    if (range.location != NSNotFound) {
        return [rawString substringFromIndex:range.location];
    }
    return rawString;
}

static BOOL isValidVideoFile(NSURL *fileURL) {
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    return [asset isPlayable] && asset.tracks.count > 0;
}

@interface _TtC16NoFacePixelsCore32PixelsFeedItemRootViewController : UIViewController <NSURLSessionDownloadDelegate>
- (void)saveVideoToPhotos;
- (void)showSuccessAlertWithMessage:(NSString *)message;
- (void)showErrorAlertWithMessage:(NSString *)message;
- (void)cancelDownloading:(UIButton *)sender;
- (MBProgressHUD *)findHUD;
- (MBProgressHUD *)findHUDRecursive:(UIView *)view;
- (MBProgressHUD *)createHUDForView:(UIView *)view withMessage:(NSString *)message;
- (void)saveToPhotoLibrary:(NSURL *)localURL;
@end

@interface _TtC16NoFacePixelsCore14FeedPlayerView : UIView
@end

static _TtC16NoFacePixelsCore14FeedPlayerView *findActiveFeedPlayerInSubviews(UIView *view) {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"_TtC16NoFacePixelsCore14FeedPlayerView")]) {
            return (_TtC16NoFacePixelsCore14FeedPlayerView *)subview;
        }
        _TtC16NoFacePixelsCore14FeedPlayerView *found = findActiveFeedPlayerInSubviews(subview);
        if (found) return found;
    }
    return nil;
}

%hook _TtC16NoFacePixelsCore32PixelsFeedItemRootViewController

%new
- (MBProgressHUD *)findHUD {
    MBProgressHUD *hud = objc_getAssociatedObject(self, CurrentHUDKey);
    if (hud && !hud.hidden) return hud;
    
    MBProgressHUD *standardHUD = [MBProgressHUD HUDForView:self.view];
    if (standardHUD && !standardHUD.hidden) return standardHUD;
    
    return [self findHUDRecursive:self.view];
}

%new
- (MBProgressHUD *)findHUDRecursive:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:%c(MBProgressHUD)]) {
            return (MBProgressHUD *)subview;
        }
        MBProgressHUD *found = [self findHUDRecursive:subview];
        if (found) return found;
    }
    return nil;
}

%new
- (MBProgressHUD *)createHUDForView:(UIView *)view withMessage:(NSString *)message {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.animationType = MBProgressHUDAnimationFade;
    hud.translatesAutoresizingMaskIntoConstraints = NO;
    hud.removeFromSuperViewOnHide = YES;

    for (UIView *subview in hud.bezelView.subviews) {
        if ([subview isKindOfClass:%c(_UIBackdropView)] || [subview isKindOfClass:[UIVisualEffectView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    Class glassEffectClass = NSClassFromString(@"UIGlassEffect");
    if (glassEffectClass && @available(iOS 26.0, *)) {
        id glassEffect = [[glassEffectClass alloc] init];
        [glassEffect setValue:[UIColor colorWithWhite:0 alpha:0.3] forKey:@"tintColor"];
        [glassEffect setValue:@(YES) forKey:@"interactive"];

        UIVisualEffectView *glassView = [[UIVisualEffectView alloc] initWithEffect:glassEffect];
        glassView.frame = hud.bezelView.bounds;
        glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        glassView.layer.cornerRadius = 22.0;
        glassView.layer.masksToBounds = YES;
        glassView.backgroundColor = UIColor.clearColor;

        hud.bezelView.backgroundColor = UIColor.clearColor;
        [hud.bezelView insertSubview:glassView atIndex:0];
    } else {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        effectView.frame = hud.bezelView.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        effectView.layer.cornerRadius = 22.0;
        effectView.layer.masksToBounds = YES;
        [hud.bezelView insertSubview:effectView atIndex:0];
    }
    
    hud.bezelView.layer.cornerRadius = 22.0;
    hud.bezelView.layer.masksToBounds = YES;
    hud.bezelView.backgroundColor = UIColor.clearColor;

    hud.margin = 2.0;
    hud.minSize = CGSizeMake(160.0, 46.0);
    hud.backgroundView.color = UIColor.clearColor;

    hud.detailsLabel.text = message ?: [[BHTBundle sharedBundle] localizedStringForKey:@"Done"];
    hud.detailsLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    hud.detailsLabel.textColor = [UIColor labelColor];
    hud.detailsLabel.textAlignment = NSTextAlignmentCenter;

    [NSLayoutConstraint activateConstraints:@[
        [hud.topAnchor constraintEqualToAnchor:view.topAnchor constant:100.0],
        [hud.centerXAnchor constraintEqualToAnchor:view.centerXAnchor]
    ]];

    [view bringSubviewToFront:hud];
    [hud hideAnimated:YES afterDelay:1.5];

    return hud;
}

- (void)viewDidLoad {
    %orig;
    UIContextMenuInteraction *interaction = [[UIContextMenuInteraction alloc] initWithDelegate:(id<UIContextMenuInteractionDelegate>)self];
    [self.view addInteraction:interaction];
}

%new
- (UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
configurationForMenuAtLocation:(CGPoint)location {
    
    CGFloat viewW = self.view.bounds.size.width;
    CGFloat viewH = self.view.bounds.size.height;
    
    CGFloat disabledRatio = 0.7;
    CGFloat disabledHeight = viewH * disabledRatio;
    
    CGRect disabledZone = CGRectMake(0, 0, viewW, disabledHeight);
    
    if (CGRectContainsPoint(disabledZone, location)) {
        return nil;
    }
    
    __weak typeof(self) weakSelf = self;
    
    _TtC16NoFacePixelsCore14FeedPlayerView *playerView = findActiveFeedPlayerInSubviews(weakSelf.view);
    AVPlayerLayer *playerLayer = playerView && [playerView.layer isKindOfClass:[AVPlayerLayer class]] ? (AVPlayerLayer *)playerView.layer : nil;
    
    AVPlayer *player = playerLayer.player;
    AVPlayerItem *item = player.currentItem;
    if (!playerLayer || !player || !item || item.status != AVPlayerItemStatusReadyToPlay) {}
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"NoFace_NoFaceDesignSystem" ofType:@"bundle"];
    NSBundle *designBundle = [NSBundle bundleWithPath:bundlePath];
    
    UIImage *downloadIcon = [UIImage imageNamed:@"NoFace/Symbols/download"
                                       inBundle:designBundle
                  compatibleWithTraitCollection:nil];
    
    UIImage *linkIcon = [UIImage imageNamed:@"NoFace/Symbols/link"
                                   inBundle:designBundle
              compatibleWithTraitCollection:nil];
    
    UIImage *searchIcon = [UIImage imageNamed:@"NoFace/Symbols/search-outline"
                                     inBundle:designBundle
                compatibleWithTraitCollection:nil];
    
    return [UIContextMenuConfiguration configurationWithIdentifier:nil
                                                   previewProvider:nil
                                                    actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {
        
        UIAction *download = [UIAction actionWithTitle:[[BHTBundle sharedBundle] localizedStringForKey:@"Download"]
                                                 image:downloadIcon
                                            identifier:nil
                                               handler:^(__kindof UIAction * _Nonnull action) {
            [weakSelf saveVideoToPhotos];
        }];
        
        UIAction *copyLink = [UIAction actionWithTitle:[[BHTBundle sharedBundle] localizedStringForKey:@"Copy link"]
                                                 image:linkIcon
                                            identifier:nil
                                               handler:^(__kindof UIAction * _Nonnull action) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                AVPlayer *activePlayer = findActivePlayerInSubviews(weakSelf.view);
                AVPlayerItem *activeItem = activePlayer.currentItem;
                NSURL *videoURL = [(AVURLAsset *)activeItem.asset URL];

                if (videoURL) {
                    NSString *cleanString = cleanHTTPURLFromString(videoURL.absoluteString);

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIPasteboard generalPasteboard] setString:cleanString];
                        [weakSelf createHUDForView:weakSelf.view
                                       withMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"Done"]];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showErrorAlertWithMessage:
                            [[BHTBundle sharedBundle] localizedStringForKey:@"No link"]];
                    });
                }
            });
        }];
        
        UIAction *openLinkAction = [UIAction actionWithTitle:[[BHTBundle sharedBundle] localizedStringForKey:@"Quick search"]
                                                       image:searchIcon
                                                  identifier:nil
                                                     handler:^(__kindof UIAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            NSString *clipboardString = pasteboard.string;
            
            if (clipboardString == nil || clipboardString.length == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showErrorAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"No link"]];
                });
                return;
            }
            
            NSString *httpsPrefix = @"https://sora.chatgpt.com/p/";
            NSString *urlSchemePrefix = @"com.openai.noface://sora.chatgpt.com/p/";
            NSString *targetURLString = nil;
            
            if ([clipboardString hasPrefix:httpsPrefix]) {
                NSString *path = [clipboardString substringFromIndex:httpsPrefix.length];
                targetURLString = [urlSchemePrefix stringByAppendingString:path];
            } else if ([clipboardString hasPrefix:urlSchemePrefix]) {
                targetURLString = clipboardString;
            } else {
                NSRange range = [clipboardString rangeOfString:@"sora.chatgpt.com/p/"];
                if (range.location != NSNotFound) {
                    NSString *path = [clipboardString substringFromIndex:range.location + range.length];
                    targetURLString = [urlSchemePrefix stringByAppendingString:path];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showErrorAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"No link"]];
                    });
                    [pasteboard setString:@""];
                    return;
                }
            }
            
            NSURL *url = [NSURL URLWithString:targetURLString];
            if (url) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showErrorAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"Error"]];
                });
            }
            
            [pasteboard setString:@""];
        }];
        
        return [UIMenu menuWithTitle:@"" children:@[download, copyLink, openLinkAction]];
    }];
}

%new
- (_UIContextMenuStyle *)_contextMenuInteraction:(UIContextMenuInteraction *)interaction
styleForMenuWithConfiguration:(UIContextMenuConfiguration *)configuration {
    _UIContextMenuStyle *style = [_UIContextMenuStyle defaultStyle];
    style.preferredLayout = 3;
    return style;
}

%new
- (void)saveVideoToPhotos {
    AVPlayer *activePlayer = findActivePlayerInSubviews(self.view);
    AVPlayerItem *item = activePlayer.currentItem;
    AVAsset *asset = item.asset;
    NSURL *videoURL = ([asset isKindOfClass:[AVURLAsset class]]) ? [(AVURLAsset *)asset URL] : nil;
    
    if (!activePlayer || !item || !videoURL) {
        [self showErrorAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"No video"]];
        return;
    }
    
    if ([self findHUD]) return;

    NSString *cleanString = cleanHTTPURLFromString(videoURL.absoluteString);
    NSURL *cleanVideoURL = [NSURL URLWithString:cleanString];
    
    if (!cleanVideoURL) {
        [self showErrorAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"Error"]];
        return;
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.animationType = MBProgressHUDAnimationFade;
    hud.translatesAutoresizingMaskIntoConstraints = NO;
    hud.removeFromSuperViewOnHide = YES;

    for (UIView *subview in hud.bezelView.subviews) {
        if ([subview isKindOfClass:%c(_UIBackdropView)] || [subview isKindOfClass:[UIVisualEffectView class]]) {
            [subview removeFromSuperview];
        }
    }

    Class glassEffectClass = %c(UIGlassEffect);
    if (glassEffectClass && @available(iOS 26.0, *)) {
        UIGlassEffect *glassEffect = [[glassEffectClass alloc] init];
        [glassEffect setValue:[UIColor colorWithWhite:0 alpha:0.3] forKey:@"tintColor"];
        [glassEffect setValue:@(YES) forKey:@"interactive"];

        UIVisualEffectView *glassView = [[UIVisualEffectView alloc] initWithEffect:glassEffect];
        glassView.frame = hud.bezelView.bounds;
        glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        glassView.layer.cornerRadius = 22.0;
        glassView.layer.masksToBounds = YES;
        glassView.alpha = 1.0;
        glassView.backgroundColor = UIColor.clearColor;

        hud.bezelView.backgroundColor = UIColor.clearColor;
        [hud.bezelView insertSubview:glassView atIndex:0];
    } else {
        UIBlurEffect *fallbackBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:fallbackBlur];
        blurView.frame = hud.bezelView.bounds;
        blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blurView.layer.cornerRadius = 22.0;
        blurView.layer.masksToBounds = YES;
        [hud.bezelView insertSubview:blurView atIndex:0];
    }

    hud.bezelView.layer.cornerRadius = 22.0;
    hud.bezelView.layer.masksToBounds = YES;
    hud.bezelView.backgroundColor = UIColor.clearColor;
    
    hud.margin = 2.0;
    hud.minSize = CGSizeMake(160.0, 48.0);
    hud.backgroundView.color = UIColor.clearColor;
    hud.detailsLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    hud.detailsLabel.textColor = UIColor.labelColor;
    hud.detailsLabel.textAlignment = NSTextAlignmentCenter;
    
    hud.layer.shadowColor = UIColor.blackColor.CGColor;
    hud.layer.shadowOpacity = 0.25;
    hud.layer.shadowRadius = 12.0;
    hud.layer.shadowOffset = CGSizeMake(0, 5);
    
    [NSLayoutConstraint activateConstraints:@[
        [hud.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:100.0],
        [hud.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
    ]];

    [self.view bringSubviewToFront:hud];
    objc_setAssociatedObject(self, CurrentHUDKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.tag = 998;
    [cancelButton setImage:[UIImage systemImageNamed:@"xmark.circle.fill"] forState:UIControlStateNormal];
    cancelButton.tintColor = [UIColor secondaryLabelColor];
    cancelButton.alpha = 0.8;
    [cancelButton addTarget:self action:@selector(cancelDownloading:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [hud.bezelView addSubview:cancelButton];

    [NSLayoutConstraint activateConstraints:@[
        [cancelButton.leadingAnchor constraintEqualToAnchor:hud.bezelView.leadingAnchor constant:6],
        [cancelButton.centerYAnchor constraintEqualToAnchor:hud.bezelView.centerYAnchor],
        [cancelButton.widthAnchor constraintEqualToConstant:22],
        [cancelButton.heightAnchor constraintEqualToConstant:22]
    ]];

    NSString *uniqueFileName = [NSString stringWithFormat:@"%@.mp4", [[NSUUID UUID] UUIDString]];
    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:uniqueFileName];
    NSURL *localURL = [NSURL fileURLWithPath:tmpPath];
    objc_setAssociatedObject(self, CurrentLocalURLKey, localURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([cleanVideoURL isFileURL]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *copyError = nil;
            [[NSFileManager defaultManager] copyItemAtURL:cleanVideoURL toURL:localURL error:&copyError];
            dispatch_async(dispatch_get_main_queue(), ^{
                MBProgressHUD *progressHUD = [self findHUD];
                [progressHUD hideAnimated:YES];
                objc_setAssociatedObject(self, CurrentHUDKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                if (copyError) {
                    [self showErrorAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"Copy failed"]];
                } else if (!isValidVideoFile(localURL)) {
                    [self showErrorAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"Error"]];
                } else {
                    [self saveToPhotoLibrary:localURL];
                }
            });
        });
        return;
    }

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 30.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:cleanVideoURL];
    objc_setAssociatedObject(self, DownloadTaskKey, downloadTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [downloadTask resume];
}

%new
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self findHUD];
        if (hud && totalBytesExpectedToWrite > 0) {
            float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
            hud.detailsLabel.text = [NSString stringWithFormat:@"%d%%", (int)(progress * 100)];
        }
    });
}

%new
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didFinishDownloadingToURL:(NSURL *)location {
    
    NSURL *localURL = objc_getAssociatedObject(self, CurrentLocalURLKey);
    if (!localURL) return;
    
    NSError *copyError = nil;
    [[NSFileManager defaultManager] removeItemAtURL:localURL error:nil];
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:localURL error:&copyError];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [self findHUD];
        
        if (copyError || !isValidVideoFile(localURL)) {
            if (hud) {
                [hud hideAnimated:YES];
                objc_setAssociatedObject(self, CurrentHUDKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            [self showErrorAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"File corrupted"]];
            return;
        }
        
        if (hud) {
            [hud hideAnimated:YES];
            objc_setAssociatedObject(self, CurrentHUDKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        [self saveToPhotoLibrary:localURL];
    });
}

%new
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [self findHUD];
            if (hud) {
                [hud hideAnimated:YES];
                objc_setAssociatedObject(self, CurrentHUDKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            [self showErrorAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"Cancelled"]];
        });
    }
    [session finishTasksAndInvalidate];
}

%new
- (void)cancelDownloading:(UIButton *)sender {
    MBProgressHUD *hud = [self findHUD];
    if (hud) {
        [hud hideAnimated:YES];
        objc_setAssociatedObject(self, CurrentHUDKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    NSURLSessionDownloadTask *downloadTask = objc_getAssociatedObject(self, DownloadTaskKey);
    if (downloadTask) [downloadTask cancel];

    NSURL *localURL = objc_getAssociatedObject(self, CurrentLocalURLKey);
    if (localURL) [[NSFileManager defaultManager] removeItemAtURL:localURL error:nil];

    cleanCFNetworkTempFiles();
    objc_setAssociatedObject(self, CurrentLocalURLKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, DownloadTaskKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self showErrorAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"Cancelled"]];
}

%new
- (void)saveToPhotoLibrary:(NSURL *)localURL {
    if (!isValidVideoFile(localURL)) {
        [self showErrorAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"Error"]];
        return;
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:localURL];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self showSuccessAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"Done"]];
            } else {
                [self showErrorAlertWithMessage:[[BHTBundle sharedBundle] localizedStringForKey:@"Error"]];
            }
            
            NSError *removeError = nil;
            [[NSFileManager defaultManager] removeItemAtURL:localURL error:&removeError];
            cleanCFNetworkTempFiles();
            objc_setAssociatedObject(self, CurrentLocalURLKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(self, DownloadTaskKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        });
    }];
}

%new
- (void)showSuccessAlertWithMessage:(NSString *)message {
    [self createHUDForView:self.view withMessage:message];
}

%new
- (void)showErrorAlertWithMessage:(NSString *)message {
    [self createHUDForView:self.view withMessage:message];
}

%end

//%hook UIScreen
//
//- (BOOL)isCaptured {
//    return NO;
//}
//
//- (void)_setCaptured:(BOOL)captured {
//    %orig(NO);
//}
//
//- (UIScreen *)mirroredScreen {
//    return nil;
//}
//
//%end

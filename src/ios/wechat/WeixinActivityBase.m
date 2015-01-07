//
//  WeixinActivity.m
//  WeixinActivity
//
//  Created by Johnny iDay on 13-12-2.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import "WeixinActivityBase.h"


@implementation WeixinActivityBase

@synthesize photoPath;

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        for (id activityItem in activityItems) {
            if ([activityItem isKindOfClass:[UIImage class]]) {
                return YES;
            }
            if ([activityItem isKindOfClass:[NSURL class]]) {
                photoPath = activityItem;
                return YES;
            }
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            image = activityItem;
        }
        if ([activityItem isKindOfClass:[NSURL class]]) {
            url = activityItem;
        }
        if ([activityItem isKindOfClass:[NSString class]]) {
            title = activityItem;
        }
    }
}

- (void)setThumbImage:(SendMessageToWXReq *)req
{
    if (image) {
        CGFloat width = 100.0f;
        CGFloat height = image.size.height * 100.0f / image.size.width;
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [image drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [req.message setThumbImage:scaledImage];
    }
}

- (void)performActivity
{
    //[self sendImageContent:photoPath];
    [self sendLinkContent];
}

- (void) sendImageContent: (NSURL*)filePath
{
    //compress the photo for wechat send
    NSString * fileName = [[filePath absoluteString] lastPathComponent];
   // compress *comp = [[compress alloc]init];
   // NSString *dstPath = [NSString stringWithFormat:@"%@/%@", [Utils applicationCompressTempDirectory], fileName];
    NSString * subFilePath = [[filePath absoluteString] substringFromIndex:7];
   // [comp compressImageFromPath:subFilePath toDstDir:dstPath];
    
    WXMediaMessage *message = [WXMediaMessage message];
    //[message setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:dstPath]]];
    
    WXImageObject *ext = [WXImageObject object];
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res5thumb" ofType:@"png"];
   // ext.imageData = [NSData dataWithContentsOfFile:dstPath];
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
    
    NSError *error;
   // [[NSFileManager defaultManager] removeItemAtPath:dstPath error:&error];
    
    [self activityDidFinish:YES];
}

- (void) sendLinkContent
{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.scene = scene;
    //    req.bText = NO;
    req.message = WXMediaMessage.message;
    if (scene == WXSceneSession) {
        //req.message.title = [NSString stringWithFormat:NSLocalizedString(@"%@ Share",nil), NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", nil)];
        req.message.description = title;
    } else {
        req.message.title = title;
    }
    [self setThumbImage:req];
    if (url) {
        WXWebpageObject *webObject = WXWebpageObject.object;
        webObject.webpageUrl = [url absoluteString];
        req.message.mediaObject = webObject;
    } else if (image) {
        WXImageObject *imageObject = WXImageObject.object;
        imageObject.imageData = UIImageJPEGRepresentation(image, 1);
        req.message.mediaObject = imageObject;
    }
    [WXApi sendReq:req];
    [self activityDidFinish:YES];

}

@end

//
//  WeixinSessionActivity.m
//  WeixinActivity
//
//  Created by Johnny iDay on 13-12-2.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import "WeixinSessionActivity.h"

@implementation WeixinSessionActivity

- (UIImage *)activityImage
{
    return [[[UIDevice currentDevice] systemVersion] intValue] >= 8 ? [UIImage imageNamed:@"icon_session-8@2x.png"] : [UIImage imageNamed:@"icon_session-8@2x.png"];
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"WeChat Session", nil);
}

@end

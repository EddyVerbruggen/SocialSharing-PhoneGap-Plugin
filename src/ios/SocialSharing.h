#import <Cordova/CDV.h>

@interface SocialSharing : CDVPlugin

- (void)available:(CDVInvokedUrlCommand*)command;
- (void)share:(CDVInvokedUrlCommand*)command;

@end
#import <Cordova/CDV.h>

@interface SocialSharing : CDVPlugin

- (void)available:(CDVInvokedUrlCommand*)command;
- (void)share:(CDVInvokedUrlCommand*)command;
- (void)shareVia:(CDVInvokedUrlCommand*)command;
- (void)shareViaTwitter:(CDVInvokedUrlCommand*)command;
- (void)shareViaFacebook:(CDVInvokedUrlCommand*)command;

@end
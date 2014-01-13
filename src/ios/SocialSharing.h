#import <Cordova/CDV.h>

@interface SocialSharing : CDVPlugin

@property (retain) UIDocumentInteractionController * documentInteractionController;

- (void)available:(CDVInvokedUrlCommand*)command;
- (void)share:(CDVInvokedUrlCommand*)command;
- (void)shareVia:(CDVInvokedUrlCommand*)command;
- (void)shareViaTwitter:(CDVInvokedUrlCommand*)command;
- (void)shareViaFacebook:(CDVInvokedUrlCommand*)command;
- (void)shareViaWhatsApp:(CDVInvokedUrlCommand*)command;

@end
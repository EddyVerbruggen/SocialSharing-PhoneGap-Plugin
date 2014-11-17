#import <Cordova/CDV.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <UIKit/UIKit.h>
#import "RDActivityViewController.h"

@interface SocialSharing : CDVPlugin <UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate, RDActivityViewControllerDelegate>

@property (nonatomic, strong) MFMailComposeViewController *globalMailComposer;
@property (retain) UIDocumentInteractionController * documentInteractionController;
@property (retain) NSString * tempStoredFile;
@property (retain) CDVInvokedUrlCommand * command;
@property (retain) NSDictionary * shareActivityData;

- (void)available:(CDVInvokedUrlCommand*)command;
- (void)share:(CDVInvokedUrlCommand*)command;
- (void)canShareVia:(CDVInvokedUrlCommand*)command;
- (void)canShareViaEmail:(CDVInvokedUrlCommand*)command;
- (void)shareVia:(CDVInvokedUrlCommand*)command;
- (void)shareViaTwitter:(CDVInvokedUrlCommand*)command;
- (void)shareViaFacebook:(CDVInvokedUrlCommand*)command;
- (void)shareViaFacebookWithPasteMessageHint:(CDVInvokedUrlCommand*)command;
- (void)shareViaWhatsApp:(CDVInvokedUrlCommand*)command;
- (void)shareViaSMS:(CDVInvokedUrlCommand*)command;
- (void)shareViaEmail:(CDVInvokedUrlCommand*)command;

@end
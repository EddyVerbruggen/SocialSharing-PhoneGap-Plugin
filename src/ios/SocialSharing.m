#import "SocialSharing.h"
#import <Cordova/CDV.h>
#import <Social/Social.h>

@implementation SocialSharing

- (void)available:(CDVInvokedUrlCommand*)command {
    NSString *callbackId = command.callbackId;

    BOOL avail = false;
    if (NSClassFromString(@"UIActivityViewController")) {
      avail = true;
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:avail];
    [self writeJavascript:[pluginResult toSuccessCallbackString:callbackId]];
}

- (void)share:(CDVInvokedUrlCommand*)command {

    if (!NSClassFromString(@"UIActivityViewController")) {
      CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not available"];
      [self writeJavascript:[pluginResult toErrorCallbackString:command.callbackId]];
      return;
    }
    
    NSString *message   = [command.arguments objectAtIndex:0];
    NSString *subject   = [command.arguments objectAtIndex:1];
    NSString *imageName = [command.arguments objectAtIndex:2];
    NSString *urlString = [command.arguments objectAtIndex:3];

    // handle URL
    NSURL *url = nil;
    if (urlString != (id)[NSNull null]) {
      url = [NSURL URLWithString:urlString];
    }
    
    // handle image
    UIImage *image = [self getImage:imageName];
    
    // Facebook gets really confused when passing a nil image or url
    NSArray *activityItems;
    if (image != nil) {
      if (url == nil) {
        activityItems = [[NSArray alloc] initWithObjects:message, image, nil];
      } else {
        activityItems = [[NSArray alloc] initWithObjects:message, image, url, nil];
      }
    } else if (url != nil) {
      activityItems = [[NSArray alloc] initWithObjects:message, url, nil];
    } else {
      activityItems = [[NSArray alloc] initWithObjects:message, nil];
    }
    
    UIActivity *activity = [[UIActivity alloc] init];
    NSArray *applicationActivities = [[NSArray alloc] initWithObjects:activity, nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    if (subject != (id)[NSNull null]) {
      [activityVC setValue:subject forKey:@"subject"];
    }
    
    [self.viewController presentViewController:activityVC animated:YES completion:nil];
    CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self writeJavascript:[pluginResult toSuccessCallbackString:command.callbackId]];
}

- (void)shareViaTwitter:(CDVInvokedUrlCommand*)command {
    [self shareVia:command type:SLServiceTypeTwitter];
}

- (void)shareViaFacebook:(CDVInvokedUrlCommand*)command {
    [self shareVia:command type:SLServiceTypeFacebook];
}

- (void)shareVia:(CDVInvokedUrlCommand*)command
            type:(NSString *) type {

    NSString *message   = [command.arguments objectAtIndex:0];
    NSString *imageName = [command.arguments objectAtIndex:1];
    NSString *urlString = [command.arguments objectAtIndex:2];
    
    if ([SLComposeViewController isAvailableForServiceType:type]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:type];
        [tweetSheet setInitialText:message];
        UIImage* image = [self getImage:imageName];
        if (image != nil) {
            [tweetSheet addImage:image];
        }
        if (urlString != (id)[NSNull null]) {
            [tweetSheet addURL:[NSURL URLWithString:urlString]];
        }
        [self.viewController presentViewController:tweetSheet animated:YES completion:nil];
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self writeJavascript:[pluginResult toSuccessCallbackString:command.callbackId]];
    } else {
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not available"];
        [self writeJavascript:[pluginResult toErrorCallbackString:command.callbackId]];
    }
}

-(UIImage*)getImage: (NSString *)imageName {
    UIImage *image = nil;
    if (imageName != (id)[NSNull null]) {
        if ([imageName rangeOfString:@"http"].location == 0) { // from the internet?
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageName]]];
        } else if ([imageName rangeOfString:@"www/"].location == 0) { // www folder?
            image = [UIImage imageNamed:imageName];
        } else if ([imageName rangeOfString:@"file://"].location == 0) {
            // using file: protocol? then strip the file:// part
            image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSURL URLWithString:imageName] path]]];
        } else {
            // assume anywhere else, on the local filesystem
            image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageName]];
        }
    }
    return image;
}

@end
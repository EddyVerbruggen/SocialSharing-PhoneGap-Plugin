#import "SocialSharing.h"
#import <Cordova/CDV.h>
#import <Social/Social.h>
#import <Foundation/NSException.h>

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

    // When done, call the successhandler. In case something was actually shares, return true, otherwise false.
    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:completed];
        [self writeJavascript:[pluginResult toSuccessCallbackString:command.callbackId]];
    }];
}

- (void)shareViaTwitter:(CDVInvokedUrlCommand*)command {
    [self shareViaInternal:command type:SLServiceTypeTwitter];
}

- (void)shareViaFacebook:(CDVInvokedUrlCommand*)command {
    [self shareViaInternal:command type:SLServiceTypeFacebook];
}

- (void)shareVia:(CDVInvokedUrlCommand*)command {
    [self shareViaInternal:command type:[command.arguments objectAtIndex:4]];
}

- (void)shareViaInternal:(CDVInvokedUrlCommand*)command
                    type:(NSString *) type {
    
    NSString *message   = [command.arguments objectAtIndex:0];
    // subject is not supported by the SLComposeViewController
    NSString *imageName = [command.arguments objectAtIndex:2];
    NSString *urlString = [command.arguments objectAtIndex:3];

    // wrapped in try-catch, because isAvailableForServiceType the app may crash if an invalid type is passed to isAvailableForServiceType
    @try {
      if (![SLComposeViewController isAvailableForServiceType:type]) {
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not available"];
        [self writeJavascript:[pluginResult toErrorCallbackString:command.callbackId]];
        return;
      }
    }
    @catch (NSException* exception) {
      CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not supported"];
      [self writeJavascript:[pluginResult toErrorCallbackString:command.callbackId]];
      return;
    }
   
    // we can now safely assume the app can be opened via the SLComposeViewController
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:type];
    [composeViewController setInitialText:message];
    UIImage* image = [self getImage:imageName];
    if (image != nil) {
      [composeViewController addImage:image];
    }
    if (urlString != (id)[NSNull null]) {
      [composeViewController addURL:[NSURL URLWithString:urlString]];
    }
    [self.viewController presentViewController:composeViewController animated:YES completion:nil];
    CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self writeJavascript:[pluginResult toSuccessCallbackString:command.callbackId]];
}

- (void)shareViaWhatsApp:(CDVInvokedUrlCommand*)command {
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]]) {
        NSString *message   = [command.arguments objectAtIndex:0];
        // subject is not supported by the SLComposeViewController
        NSString *imageName = [command.arguments objectAtIndex:2];
        NSString *urlString = [command.arguments objectAtIndex:3];

        // with WhatsApp, we can share an image OR text+url.. image wins if set
        UIImage* image = [self getImage:imageName];
        if (image != nil) {
            NSString * savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/whatsAppTmp.wai"];
            [UIImageJPEGRepresentation(image, 1.0) writeToFile:savePath atomically:YES];
            _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
            _documentInteractionController.UTI = @"net.whatsapp.image";
            [_documentInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.viewController.view animated: YES];
        } else {
            // append an url to a message, if both are passed
            NSString * shareString = @"";
            if (message != (id)[NSNull null]) {
                shareString = message;
            }
            if (urlString != (id)[NSNull null]) {
                if ([shareString isEqual: @""]) {
                    shareString = urlString;
                } else {
                    shareString = [NSString stringWithFormat:@"%@ %@", shareString, urlString];
                }
            }
            NSString * encodedShareString = [shareString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            NSString * encodedShareStringForWhatsApp = [NSString stringWithFormat:@"whatsapp://send?text=%@", encodedShareString];

            NSURL *whatsappURL = [NSURL URLWithString:encodedShareStringForWhatsApp];
            [[UIApplication sharedApplication] openURL: whatsappURL];
        }
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
      } else if ([imageName rangeOfString:@"data:"].location == 0) {
        // using a base64 encoded string
        NSURL *imageURL = [NSURL URLWithString:imageName];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        image = [UIImage imageWithData:imageData];
      } else {
        // assume anywhere else, on the local filesystem
        image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageName]];
      }
    }
    return image;
}


@end
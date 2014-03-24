#import "SocialSharing.h"
#import <Cordova/CDV.h>
#import <Social/Social.h>
#import <Foundation/NSException.h>
#import <MessageUI/MFMessageComposeViewController.h>

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
    NSString *fileName  = [command.arguments objectAtIndex:2];
    NSString *urlString = [command.arguments objectAtIndex:3];

    // handle URL
    NSURL *url = nil;
    if (urlString != (id)[NSNull null]) {
      url = [NSURL URLWithString:urlString];
    }

    // handle file (which may be an image)
    NSObject *file = [self getImage:fileName];
    if (file == nil) {
      file = [self getFile:fileName];
    }

    // Facebook (and maybe others) gets really confused when passing a nil image or url
    NSArray *activityItems;
    if (file != nil) {
      if (url == nil) {
        activityItems = @[message, file];
      } else {
        activityItems = @[message, file, url];
      }
    } else if (url != nil) {
      activityItems = @[message, url];
    } else {
      activityItems = @[message];
    }

    UIActivity *activity = [[UIActivity alloc] init];
    NSArray *applicationActivities = [[NSArray alloc] initWithObjects:activity, nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    if (subject != (id)[NSNull null]) {
      [activityVC setValue:subject forKey:@"subject"];
    }

    [self.viewController presentViewController:activityVC animated:YES completion:nil];

    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
        [self cleanupStoredFiles];
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

- (void)canShareVia:(CDVInvokedUrlCommand*)command {
    NSString *via = [command.arguments objectAtIndex:4];
    if ([@"sms" caseInsensitiveCompare:via] == NSOrderedSame && [self canShareViaSMS]) {
      CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self writeJavascript:[pluginResult toSuccessCallbackString:command.callbackId]];
    } else if ([@"whatsapp" caseInsensitiveCompare:via] == NSOrderedSame && [self canShareViaWhatsApp]) {
      CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self writeJavascript:[pluginResult toSuccessCallbackString:command.callbackId]];
    } else if ([self isAvailableForSharing:command type:via]) {
      CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self writeJavascript:[pluginResult toSuccessCallbackString:command.callbackId]];
    } else {
      CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not available"];
      [self writeJavascript:[pluginResult toErrorCallbackString:command.callbackId]];
    }
}

// TODO consider mail sharing: http://stackoverflow.com/questions/9656478/uiimage-send-to-email
// .. also see code of 'email composer' plugins

- (bool)isAvailableForSharing:(CDVInvokedUrlCommand*)command
                         type:(NSString *) type {
    // wrapped in try-catch, because isAvailableForServiceType the app may crash if an invalid type is passed to isAvailableForServiceType
    @try {
        return [SLComposeViewController isAvailableForServiceType:type];
    }
    @catch (NSException* exception) {
        return false;
    }
}

- (void)shareViaInternal:(CDVInvokedUrlCommand*)command
                    type:(NSString *) type {

    NSString *message   = [command.arguments objectAtIndex:0];
    // subject is not supported by the SLComposeViewController
    NSString *imageName = [command.arguments objectAtIndex:2];
    NSString *urlString = [command.arguments objectAtIndex:3];

    // boldly invoke the target app, because the phone will display a nice message asking to configure the app
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

    [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
        // now check for availability of the app and invoke the correct callback
        if ([self isAvailableForSharing:command type:type]) {
            CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:SLComposeViewControllerResultDone == result];
            [self writeJavascript:[pluginResult toSuccessCallbackString:command.callbackId]];
        } else {
            CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not available"];
            [self writeJavascript:[pluginResult toErrorCallbackString:command.callbackId]];
        }
    }];
}

- (bool)canShareViaSMS {
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    return messageClass != nil && [messageClass canSendText];
}

- (void)shareViaSMS:(CDVInvokedUrlCommand*)command {
    if ([self canShareViaSMS]) {
      MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
      picker.messageComposeDelegate = self;
      picker.body = [command.arguments objectAtIndex:0];
      NSString *phonenumbers = [command.arguments objectAtIndex:1];
      if (phonenumbers != (id)[NSNull null]) {
        [picker setRecipients:[phonenumbers componentsSeparatedByString:@","]];
      }
      // remember the command, because we need it in the didFinishWithResult method
      _command = command;
      [self.viewController presentModalViewController:picker animated:YES];
    } else {
      CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not available"];
      [self writeJavascript:[pluginResult toErrorCallbackString:command.callbackId]];
    }
}

// Dismisses the SMS composition interface when users taps Cancel or Send
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
  bool ok = result == MessageComposeResultSent;
  [self.viewController dismissModalViewControllerAnimated:YES];
  CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:ok];
  [self writeJavascript:[pluginResult toSuccessCallbackString:_command.callbackId]];
}

- (bool)canShareViaWhatsApp {
  return [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]];
}

- (void)shareViaWhatsApp:(CDVInvokedUrlCommand*)command {
    if ([self canShareViaWhatsApp]) {
        NSString *message   = [command.arguments objectAtIndex:0];
        // subject is not supported by the SLComposeViewController
        NSString *fileName  = [command.arguments objectAtIndex:2];
        NSString *urlString = [command.arguments objectAtIndex:3];

        // with WhatsApp, we can share an image OR text+url.. image wins if set
        UIImage* image = [self getImage:fileName];
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
            NSString * encodedShareString = [shareString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // also encode the '=' character
            encodedShareString = [encodedShareString stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
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
      if ([imageName rangeOfString:@"http"].location == 0) { // from the internet
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageName]]];
      } else if ([imageName rangeOfString:@"www/"].location == 0) { // www folder
        image = [UIImage imageNamed:imageName];
      } else if ([imageName rangeOfString:@"file://"].location == 0) { // using file: protocol
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

-(NSObject*)getFile: (NSString *)fileName {
    NSObject *file = nil;
    if (fileName != (id)[NSNull null]) {
      if ([fileName rangeOfString:@"http"].location == 0) { // from the internet
        NSURL *url = [NSURL URLWithString:fileName];
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        file = [NSURL fileURLWithPath:[self storeInFile:(NSString*)[[fileName componentsSeparatedByString: @"/"] lastObject] fileData:fileData]];
      } else if ([fileName rangeOfString:@"www/"].location == 0) { // www folder
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", bundlePath, fileName];
        file = [NSURL fileURLWithPath:fullPath];
      } else if ([fileName rangeOfString:@"file://"].location == 0) { // using file: protocol
        // stripping the first 6 chars, because the path should start with / instead of file://
        file = [NSURL fileURLWithPath:[fileName substringFromIndex:6]];
      } else if ([fileName rangeOfString:@"data:"].location == 0) {
        // using a base64 encoded string
        // extract some info from the 'fileName', which is for example: data:text/calendar;base64,<encoded stuff here>
        NSString *fileType = (NSString*)[[[fileName substringFromIndex:5] componentsSeparatedByString: @";"] objectAtIndex:0];
        fileType = (NSString*)[[fileType componentsSeparatedByString: @"/"] lastObject];
        NSString *base64content = (NSString*)[[fileName componentsSeparatedByString: @","] lastObject];
        NSData *fileData = [NSData dataFromBase64String:base64content];
        file = [NSURL fileURLWithPath:[self storeInFile:[NSString stringWithFormat:@"%@.%@", @"file", fileType] fileData:fileData]];
      } else {
        // assume anywhere else, on the local filesystem
        file = [NSURL fileURLWithPath:fileName];
      }
    }
    return file;
}

-(NSString*) storeInFile: (NSString*) fileName
                fileData: (NSData*) fileData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    [fileData writeToFile:filePath atomically:YES];
    _tempStoredFile = filePath;
    return filePath;
}

- (void) cleanupStoredFiles {
    if (_tempStoredFile != nil) {
      NSError *error;
      [[NSFileManager defaultManager]removeItemAtPath:_tempStoredFile error:&error];
    }
}

@end
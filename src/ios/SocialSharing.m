#import "SocialSharing.h"
#import <Cordova/CDV.h>

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
        return;
    }
  
    NSString *message = [command.arguments objectAtIndex:0];
    NSString *subject = [command.arguments objectAtIndex:1];
    NSString *imageName = [command.arguments objectAtIndex:2];
    NSString *urlString = [command.arguments objectAtIndex:3];

    NSURL *url = nil;

    UIImage *image = nil;
    if (imageName != (id)[NSNull null]) {
      if ([imageName rangeOfString:@"http"].location == 0) { // from the internet?
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageName]]];
      } else if ([imageName rangeOfString:@"www/"].location == 0) { // www folder?
        image = [UIImage imageNamed:imageName];
      } else if ([imageName rangeOfString:@"file://"].location == 0) {
        // using file: protocol? then strip the file:// part
        imageName = [[NSURL URLWithString:imageName] path];
        image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageName]];
      } else {
        // assume anywhere else, on the local filesystem
        image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageName]];
      }
      if (urlString != (id)[NSNull null]) {
        url = [NSURL URLWithString:urlString];
      }
    } else {
      // if a URL was passed, but not an image, the URL is not shown, so we append it to the message
      if (urlString != (id)[NSNull null]) {
        if (message != (id)[NSNull null]) {
          message = [NSString stringWithFormat:@"%@ %@", message, urlString];
        } else {
          message = urlString;
        }
      }
    }

    NSArray *activityItems = [[NSArray alloc] initWithObjects:message, image, url, nil];
    UIActivity *activity = [[UIActivity alloc] init];
    NSArray *applicationActivities = [[NSArray alloc] initWithObjects:activity, nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    if (subject != (id)[NSNull null]) {
      [activityVC setValue:subject forKey:@"subject"];
    }
    // you could exclude some activities based on passed properties (uncomment these lines)
    // NSArray * excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard];
    // activityVC.excludedActivityTypes = excludeActivities;
    [self.viewController presentViewController:activityVC animated:YES completion:nil];
}

@end

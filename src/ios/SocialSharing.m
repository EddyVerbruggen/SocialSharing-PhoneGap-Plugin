#import "SocialSharing.h"
#import <Cordova/CDV.h>

@implementation SocialSharing

- (void)available:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    BOOL avail = false;
    if (NSClassFromString(@"UIActivityViewController")) {
      avail = true;
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:avail];
    [self writeJavascript:[pluginResult toSuccessCallbackString:[arguments objectAtIndex:0]]];
}

- (void)share:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    
    if (!NSClassFromString(@"UIActivityViewController")) {
      return;
    }
    
    NSString *message = [arguments objectAtIndex:1];
    NSString *subject = [arguments objectAtIndex:2];
    NSString *imageName = [arguments objectAtIndex:3];
    NSString *urlString = [arguments objectAtIndex:4];

    // handle URL
    NSURL *url = nil;
    if (urlString != (id)[NSNull null]) {
      url = [NSURL URLWithString:urlString];
    }

    // handle image
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
    }

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
}

@end

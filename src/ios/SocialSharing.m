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
    
    NSString *subject = [arguments objectAtIndex:1];
    NSString *text = [arguments objectAtIndex:2];
    NSString *imageName = [arguments objectAtIndex:3];
    UIImage *image = nil;

    if (imageName) {
      if ([imageName rangeOfString:@"http"].location == 0) { // from the internet?
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageName]]];
      } else if ([imageName rangeOfString:@"www/"].location == 0) { // www folder?
        image = [UIImage imageNamed:imageName];
      } else { // assume anywhere else on the local filesystem
        image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageName]];
      }
    }

    NSArray *activityItems = [[NSArray alloc] initWithObjects:text, image, nil];

    UIActivity *activity = [[UIActivity alloc] init];

    NSArray *applicationActivities = [[NSArray alloc] initWithObjects:activity, nil];
    UIActivityViewController *activityVC =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    if (subject) {
      [activityVC setValue:subject forKey:@"subject"];
    }
    [self.viewController presentViewController:activityVC animated:YES completion:nil];
}

@end

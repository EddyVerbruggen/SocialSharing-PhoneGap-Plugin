#import <Cordova/CDV.h>

@interface SocialSharing : CDVPlugin

- (void)available:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)share:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)shareViaWhatsApp:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)canShareVia:(CDVInvokedUrlCommand*)command;

@end

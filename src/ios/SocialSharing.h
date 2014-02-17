#import <Cordova/CDV.h>

@interface SocialSharing : CDVPlugin

@property (retain) UIDocumentInteractionController * documentInteractionController;

- (void)available:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)share:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)shareViaWhatsApp:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)canShareVia:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

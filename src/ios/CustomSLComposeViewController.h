#import <Foundation/NSURL.h>
#import <Social/Social.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface CustomSLComposeViewController:SLComposeViewController

- (BOOL)addVideoURL:(NSURL *)url;

@end


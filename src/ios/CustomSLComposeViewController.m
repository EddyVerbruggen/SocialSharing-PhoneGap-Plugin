#import "CustomSLComposeViewController.h"
#import <Foundation/NSURL.h>
#import <Social/Social.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>

// This class extends SLComposeViewController and adds ability of share videos
@implementation CustomSLComposeViewController

- (BOOL)addVideoURL:(NSURL *)url {
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithItem:url typeIdentifier:(NSString *)kUTTypeMPEG4];

    NSExtensionItem *extensionItem = [NSExtensionItem new];
    extensionItem.attachments = [NSArray arrayWithObject:itemProvider];

    return [self performSelector:@selector(addExtensionItem:) withObject:extensionItem];
}

+ (CustomSLComposeViewController *)composeViewControllerForServiceType:(NSString *)serviceType{
    return (CustomSLComposeViewController *)[super composeViewControllerForServiceType:serviceType];
}
@end

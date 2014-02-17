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

- (void)canShareVia:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString *via = [arguments objectAtIndex:5];
    if ([@"whatsapp" caseInsensitiveCompare:via] == NSOrderedSame && [self canShareViaWhatsApp]) {
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self writeJavascript:[pluginResult toSuccessCallbackString:[arguments objectAtIndex:0]]];
    } else {
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not available"];
        [self writeJavascript:[pluginResult toErrorCallbackString:[arguments objectAtIndex:0]]];
    }
}

- (bool)canShareViaWhatsApp {
    return [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]];
}

- (void)shareViaWhatsApp:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    if ([self canShareViaWhatsApp]) {
        NSString *message = [arguments objectAtIndex:1];
        NSString *subject = [arguments objectAtIndex:2];
        NSString *fileName = [arguments objectAtIndex:3];
        NSString *urlString = [arguments objectAtIndex:4];
        
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
            NSString * encodedShareString = [shareString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            NSString * encodedShareStringForWhatsApp = [NSString stringWithFormat:@"whatsapp://send?text=%@", encodedShareString];
            
            NSURL *whatsappURL = [NSURL URLWithString:encodedShareStringForWhatsApp];
            [[UIApplication sharedApplication] openURL: whatsappURL];
        }
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self writeJavascript:[pluginResult toSuccessCallbackString:[arguments objectAtIndex:0]]];
        
    } else {
        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not available"];
        [self writeJavascript:[pluginResult toErrorCallbackString:[arguments objectAtIndex:0]]];
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

@end

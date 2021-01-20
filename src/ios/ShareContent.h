#import <Foundation/NSURL.h>
#import <MobileCoreServices/MobileCoreServices.h>

typedef NS_ENUM(NSUInteger, ContentType) {
    IMAGE,
    VIDEO,
    AUDIO,
    OTHER
};

@interface ShareContent : NSObject
- (ContentType)getType;
- (void)setUrl:(NSURL *)url;
- (NSURL*)getUrl;
@end


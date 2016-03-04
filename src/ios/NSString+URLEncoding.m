#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)
- (NSString*)URLEncodedString
{
  return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                            kCFAllocatorDefault,
                            (CFStringRef)self,
                            CFSTR("#"), // don't escape these
                            NULL, // allow escaping these
                            kCFStringEncodingUTF8
                      ));
}
@end

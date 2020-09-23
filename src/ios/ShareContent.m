@implementation ShareContent {
    NSURL * _url;
    ContentType _type;
}

- (ContentType)getType {
    return _type;
};

- (void)setUrl:(NSURL *)url {
    _url = url;
    if (_url == nil)
        return;
    CFStringRef fileExtension = (__bridge CFStringRef) [url pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    NSString *type = (__bridge_transfer NSString *) MIMEType;
    if ([type hasPrefix:@"image"])
        _type = IMAGE;
    else if ([type hasPrefix:@"video"])
        _type = VIDEO;
    else if ([type hasPrefix:@"audio"])
        _type = AUDIO;
    else
        _type = OTHER;
}

- (NSURL *)getUrl {
    return _url;
};

@end

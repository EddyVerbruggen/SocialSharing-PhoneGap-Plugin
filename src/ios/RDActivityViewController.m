//
//  RDActivityViewController.m
//  APOD
//
//  Created by Robert Dougan on 11/5/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDActivityViewController.h"

@interface RDActivityViewController () {
    NSMutableDictionary *_itemsMapping;
    int _maximumNumberOfItems;
}

@end

@implementation RDActivityViewController

@synthesize delegate = _delegate;
@synthesize placeholderItem = _placeholderItem;

- (id)initWithDelegate:(id<RDActivityViewControllerDelegate>)delegate {
    return [self initWithDelegate:delegate maximumNumberOfItems:10 applicationActivities:nil placeholderItem:nil];
}

- (id)initWithDelegate:(id)delegate maximumNumberOfItems:(int)maximumNumberOfItems {
    return [self initWithDelegate:delegate maximumNumberOfItems:maximumNumberOfItems applicationActivities:nil placeholderItem:nil];
}

- (id)initWithDelegate:(id)delegate maximumNumberOfItems:(int)maximumNumberOfItems applicationActivities:(NSArray *)applicationActivities {
    return [self initWithDelegate:delegate maximumNumberOfItems:maximumNumberOfItems applicationActivities:applicationActivities placeholderItem:nil];
}

- (id)initWithDelegate:(id)delegate maximumNumberOfItems:(int)maximumNumberOfItems applicationActivities:(NSArray *)applicationActivities placeholderItem:(id)placeholderItem {
    _delegate = delegate;
    _maximumNumberOfItems = maximumNumberOfItems;
    _placeholderItem = placeholderItem;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    int i;
    
    for (i = 0; i < maximumNumberOfItems; i++) {
        [items addObject:self];
    }
    
    self = [self initWithActivityItems:items applicationActivities:applicationActivities];
    if (self) {
        _itemsMapping = [[NSMutableDictionary alloc] init];
    }
    NSLog(@"[RDActivityViewController] initWithDelegate");
    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    // Get the items if not already received
    NSMutableDictionary *activity = [_itemsMapping objectForKey:activityType];
    NSArray *items;
    
    if (!activity) {
        items = [_delegate performSelector:@selector(activityViewController:itemsForActivityType:) withObject:self withObject:activityType];
        activity = [[NSMutableDictionary alloc] initWithObjectsAndKeys:items, @"items", [NSNumber numberWithInt:0], @"index", nil];
        
        [_itemsMapping setObject:activity forKey:activityType];
    } else {
        items = [activity objectForKey:@"items"];
    }
    
    // Get the item
    int index = [[activity objectForKey:@"index"] integerValue];
    id item = nil;
    
    if (index < [items count]) {
        item = [items objectAtIndex:index];
    }
    NSLog(@"activityType: %@ index: %d item: %@", activityType, index, item);    
    // Increase the index, and reset
    index = (index + 1) % _maximumNumberOfItems;
    [activity setObject:[NSNumber numberWithInt:index] forKey:@"index"];
    
    return item;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    if(_placeholderItem == nil) { return @""; }
    return _placeholderItem;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    NSString *subject;
    if ([_delegate respondsToSelector:@selector(activityViewController:subjectForActivityType:)]) {
        subject = [_delegate
                   performSelector:@selector(activityViewController:subjectForActivityType:)
                        withObject:self
                        withObject:activityType];
    } else {
        subject = nil;
    }
    
    return subject;
}

@end

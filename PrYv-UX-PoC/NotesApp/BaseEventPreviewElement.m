//
//  BaseEventPreviewElement.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/29/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseEventPreviewElement.h"

@implementation BaseEventPreviewElement

- (UIImage*)elementPreviewImage
{
    return self.previewImage;
}

- (NSString*)elementTitle
{
    return nil;
}

- (NSString*)elementSubtitle
{
    return nil;
}

- (PYAttachment*)attachment
{
    return nil;
}

@end

//
//  TextNotePreviewElement.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/14/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "TextNotePreviewElement.h"

@implementation TextNotePreviewElement

- (UIImage*)elementPreviewImage
{
    return [UIImage imageNamed:@"icon_text"];
}

- (NSString*)elementTitle
{
    return self.textValue;
}

- (NSString*)elementSubtitle
{
    return nil;
}

- (NSString*)klass
{
    return @"note";
}

- (NSString*)format
{
    return @"txt";
}

@end

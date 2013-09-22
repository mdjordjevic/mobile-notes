//
//  PhotoPreviewElement.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PhotoPreviewElement.h"

#define kCompressionQuality 0.5f
#define kImageNameLength 10

@interface PhotoPreviewElement ()

- (NSString *)randomImageName;

@end

@implementation PhotoPreviewElement

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
    NSData *imageData = UIImageJPEGRepresentation(self.previewImage, kCompressionQuality);
    if(!imageData)
    {
        return nil;
    }
    NSString *imageName = [self randomImageName];
    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:imageName fileName:[NSString stringWithFormat:@"%@.jpeg",imageName]];
    return att;
}

- (NSString *)randomImageName
{
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:kImageNameLength];
    NSUInteger length = [alphabet length];
    for (NSUInteger i = 0U; i < kImageNameLength; i++) {
        u_int32_t r = arc4random() % length;
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return s;
}

@end

//
//  PictureCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 10/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PictureCell.h"
#import "UIImage+PrYv.h"

@implementation PictureCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.pictureView.image = nil;
}

- (void)updateWithEvent:(PYEvent *)event andListOfStreams:(NSArray *)streams
{
    if([event.attachments count] > 0)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PYAttachment *att = [event.attachments objectAtIndex:0];
            UIImage *img = [UIImage imageWithData:att.fileData];
            CGSize newSize = img.size;
            CGFloat maxSide = MAX(newSize.width, newSize.height);
            CGFloat ratio = maxSide / [self pictureView].bounds.size.width;
            newSize = CGSizeMake(floorf(newSize.width/ratio), floorf(newSize.height/ratio));
            img = [img imageScaledToSize:newSize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
                    [self.pictureView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [self.pictureView setImage:img];
                    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
                        [self.pictureView setAlpha:1.0f];
                    } completion:^(BOOL finished) {
                        
                    }];
                }];
                
            });
        });
    }
    [super updateWithEvent:event andListOfStreams:streams];
}

@end

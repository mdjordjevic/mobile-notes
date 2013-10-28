//
//  TagView.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/15/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "TagView.h"

#define kTagHeight 16.0
#define kTagFontSize 12.0

@interface TagView ()

@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic) TagViewStyle style;

+ (UILabel*)createTagLabelWithStyle:(TagViewStyle)style;

@end

@implementation TagView

- (id)initWithText:(NSString *)tagText andStyle:(TagViewStyle)style
{
    self = [super init];
    if(self)
    {
        self.style = style;
        self.tagLabel = [TagView createTagLabelWithStyle:style];
        self.tagLabel.text = tagText;
        CGSize labelSize = [tagText sizeWithFont:self.tagLabel.font];
        self.tagLabel.frame = CGRectMake(4, 0, labelSize.width, kTagHeight);
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelSize.width + 8, kTagHeight)];
        if(style == TagViewStandardStyle)
        {
            self.backgroundView.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:95.0f/255.0f blue:36.0f/255.0f alpha:1.0];
        }
        else
        {
            self.backgroundView.backgroundColor = [UIColor whiteColor];
        }
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backgroundView];
        [self addSubview:self.tagLabel];
        self.frame = self.backgroundView.frame;
    }
    return self;
}

+ (UILabel*)createTagLabelWithStyle:(TagViewStyle)style
{
    UILabel *tagLabel = [[UILabel alloc] init];
    [tagLabel setBackgroundColor:[UIColor clearColor]];
    [tagLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:kTagFontSize]];
    if(style == TagViewStandardStyle)
    {
        [tagLabel setTextColor:[UIColor whiteColor]];
    }
    else
    {
        [tagLabel setTextColor:[UIColor colorWithRed:106.0f/255.0f green:163.0f/255.0f blue:195.0f/255.0f alpha:1]];
    }
    [tagLabel setAlpha:0.8];
    return tagLabel;
}

@end

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

+ (UILabel*)createTagLabel;

@end

@implementation TagView

- (id)initWithText:(NSString *)tagText
{
    self = [super init];
    if(self)
    {
        self.tagLabel = [TagView createTagLabel];
        self.tagLabel.text = tagText;
        CGSize labelSize = [tagText sizeWithFont:self.tagLabel.font];
        self.tagLabel.frame = CGRectMake(4, 0, labelSize.width, kTagHeight);
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelSize.width + 8, kTagHeight)];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.3;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backgroundView];
        [self addSubview:self.tagLabel];
        self.frame = self.backgroundView.frame;
    }
    return self;
}

+ (UILabel*)createTagLabel
{
    UILabel *tagLabel = [[UILabel alloc] init];
    [tagLabel setBackgroundColor:[UIColor clearColor]];
    [tagLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:kTagFontSize]];
    [tagLabel setTextColor:[UIColor whiteColor]];
    [tagLabel setAlpha:0.8];
    return tagLabel;
}

@end

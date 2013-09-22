//
//  TopMenuCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "TopMenuCell.h"

@interface TopMenuCell ()

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation TopMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        self.backgroundView = nil;
        [self setBackgroundColor:[UIColor clearColor]];
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 56, 56)];
        self.imageView.image = [UIImage imageNamed:@"add_circle"];
        [self.imgView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.imgView];
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 20, 16, 16)];
        [self.iconImageView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.iconImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

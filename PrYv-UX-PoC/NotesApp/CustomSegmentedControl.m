//
//  CustomSegmentedControl.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "CustomSegmentedControl.h"

#define kLeftImageName @"icon_small_lru"
#define kLeftImageActiveName @"icon_small_lru_active"
#define kRightImageName @"icon_small_browse"
#define kRightImageActiveName @"icon_small_browse_active"
#define kLeftSelectedImage @"segment_sel_uns"
#define kRightSelectedImage @"segement_uns_sel"


@interface CustomSegmentedControl ()

@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIImageView *leftButtonImage;
@property (nonatomic, strong) UIImageView *rightButtonImage;

- (void)initObject;
- (void)updateImages;

@end

@implementation CustomSegmentedControl

- (void)awakeFromNib
{
    [self initObject];
}

- (void)initObject
{
    self.backgroundImage = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:self.backgroundImage];
    
    self.leftButtonImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    self.leftButtonImage.center = CGPointMake(37, 15);
    [self addSubview:self.leftButtonImage];
    
    self.rightButtonImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    self.rightButtonImage.center = CGPointMake(113, 15);
    [self addSubview:self.rightButtonImage];
    
    _selectedIndex = 0;
    [self updateImages];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if(point.x < self.bounds.size.width / 2)
    {
        [self selectIndex:0];
    }
    else
    {
        [self selectIndex:1];
    }
}

- (void)updateImages
{
    self.backgroundImage.image = [UIImage imageNamed: _selectedIndex ? kRightSelectedImage : kLeftSelectedImage];
    self.leftButtonImage.image = [UIImage imageNamed: _selectedIndex ? kLeftImageName : kLeftImageActiveName];
    self.rightButtonImage.image = [UIImage imageNamed: _selectedIndex ? kRightImageActiveName : kRightImageName];
}

#pragma mark - Public API

- (void)selectIndex:(NSInteger)index
{
    if(_selectedIndex == index)
    {
        return;
    }
    _selectedIndex = index;
    [self updateImages];
    [_delegate customSegmentedControl:self didSelectIndex:_selectedIndex];
}


@end

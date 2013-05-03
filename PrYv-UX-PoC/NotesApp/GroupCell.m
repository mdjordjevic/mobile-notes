//
//  GroupCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/2/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "GroupCell.h"

@interface GroupCell ()

@property (nonatomic, strong) UILabel *cellTitleLabel;

- (void)setupSubviews;

@end

@implementation GroupCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    self.cellTitleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    [_cellTitleLabel setBackgroundColor:[UIColor clearColor]];
    [_cellTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [_cellTitleLabel setFont:[UIFont systemFontOfSize:12]];
    [self addSubview:_cellTitleLabel];
    [self setBackgroundColor:[UIColor colorWithRed:228.0/255.0 green:117.0/255.0 blue:113.0/255.0 alpha:1.0]];
}

- (void)setCellTitle:(NSString *)cellTitle {
    if(![_cellTitle isEqualToString:cellTitle]) {
        _cellTitle = cellTitle;
        [_cellTitleLabel setText:_cellTitle];
    }
}

@end

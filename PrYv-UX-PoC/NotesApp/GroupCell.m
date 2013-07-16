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
@property (nonatomic, strong) NSMutableArray *itemsSubviews;

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

- (void)setDataSource:(id<GroupCellDataSource>)dataSource {
    if(![_dataSource isEqual:dataSource]) {
        _dataSource = dataSource;
    }
}

- (void)setupSubviews {
    self.cellTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    self.frame.size.width/2.0f,
                                                                    self.frame.size.height/2.0f)];
    [_cellTitleLabel setBackgroundColor:[UIColor clearColor]];
    [_cellTitleLabel setTextAlignment:UITextAlignmentCenter];
    [_cellTitleLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [_cellTitleLabel setNumberOfLines:0];
    [self addSubview:_cellTitleLabel];
    [self setBackgroundColor:[UIColor colorWithRed:239.0/255.0
                                             green:175.0/255.0
                                              blue:173.0/255.0
                                             alpha:1.0]];
    self.itemsSubviews = [NSMutableArray array];
}

- (void)updateItems {
    [_itemsSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_itemsSubviews removeAllObjects];
    NSInteger numberOfItemsInGroup = [_dataSource numberOfItemsInGroupAtIndex:_cellIndex];
    for(int i=0;i<numberOfItemsInGroup;i++) {
        if(i > 2) {
            break;
        }
        NSString *title = [_dataSource titleForItemInGroupAtIndex:_cellIndex andItemIndex:i];
        int position = (i+1)%2;
        int row = (i+1)/2;
        CGRect frame = CGRectMake(position * self.bounds.size.height/2.0f, row * self.bounds.size.height/2.0f, self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
        
        UILabel *itemLabel = [[UILabel alloc] initWithFrame:frame];
        [itemLabel setBackgroundColor:[UIColor colorWithRed:218.0/255.0
                                                      green:67.0/255.0
                                                       blue:62.0/255.0
                                                      alpha:1.0]];
        [itemLabel setTextAlignment:UITextAlignmentCenter];
        [itemLabel setFont:[UIFont systemFontOfSize:8]];
        [itemLabel setNumberOfLines:0];
        [itemLabel setText:title];
        [self addSubview:itemLabel];
        [_itemsSubviews addObject:itemLabel];
    }
}

- (void)setCellTitle:(NSString *)cellTitle {
    if(![_cellTitle isEqualToString:cellTitle]) {
        _cellTitle = cellTitle;
        [_cellTitleLabel setText:_cellTitle];
    }
}

@end

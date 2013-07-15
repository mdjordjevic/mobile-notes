//
//  BrowseEventsCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BrowseEventsCell.h"
#import "CellStyleModel.h"
#import "TagView.h"

#define kScreenSize 320

@interface BrowseEventsCell ()

@property (nonatomic, strong) IBOutlet UIView *titleSeparatorView;
@property (nonatomic, strong) IBOutlet UIView *tagContainer;

- (void)layoutForCellStyleModel:(CellStyleModel*)model;
- (NSString*)imageNameForCellStyleModel:(CellStyleModel*)model;

@end

@implementation BrowseEventsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithCellStyleModel:(CellStyleModel *)cellStyleModel
{
    CGFloat totalWidth = cellStyleModel.leftImageSize.width + cellStyleModel.rightImageSize.width;
    
    NSString *leftImageName = @"cell_left";
    UIImage *lImg = [[UIImage imageNamed:leftImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 3, 2)];
    self.leftImageView.image = lImg;
    self.leftImageView.frame = CGRectMake((kScreenSize - totalWidth) / 2, 8, cellStyleModel.leftImageSize.width, cellStyleModel.leftImageSize.height);
    
    NSString *rightImageName = [cellStyleModel cellImageName];
    UIImage *rImg = [[UIImage imageNamed:rightImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 0, 3, 2)];
    self.rightImageView.image = rImg;
    self.rightImageView.frame = CGRectMake((kScreenSize - totalWidth) / 2 + cellStyleModel.leftImageSize.width, 8, cellStyleModel.rightImageSize.width, cellStyleModel.rightImageSize.height);
    
    self.titleSeparatorView.backgroundColor = [cellStyleModel baseColorWithAlpha:0.5];
    [self.channelFolderLabel setTextColor:[cellStyleModel baseColorWithAlpha:0.5]];
    [self.valueLabel setTextColor:[cellStyleModel baseColorWithAlpha:0.5]];
    
    [self layoutForCellStyleModel:cellStyleModel];
    
    self.iconImageView.image = [UIImage imageNamed:[self imageNameForCellStyleModel:cellStyleModel]];
}

- (void)layoutForCellStyleModel:(CellStyleModel *)model
{
    if(model.cellStyleSize == CellStyleSizeBig)
    {
        self.channelFolderLabel.frame = CGRectMake(112, 8, 320 - 112 - 16, 24);
        self.valueLabel.frame = CGRectMake(112, 36, 320 - 112 - 16, 24);
        self.tagContainer.frame = CGRectMake(112, 80, 320 - 112 - 16, 16);
        self.titleSeparatorView.frame = CGRectMake(112, 30, 320 - 112 - 16, 1);
        self.iconImageView.frame = self.leftImageView.frame;
        self.valueLabel.hidden = NO;
    }
    else
    {
        self.channelFolderLabel.frame = CGRectMake(80, 8, 320 - 80 - 16, 24);
        self.valueLabel.frame = CGRectMake(80, 36, 320 - 80 - 16, 24);
        self.tagContainer.frame = CGRectMake(80, 48, 320 - 80 - 16, 16);
        self.titleSeparatorView.frame = CGRectMake(80, 30, 320 - 80 - 16, 1);
        self.iconImageView.frame = self.leftImageView.frame;
        self.valueLabel.hidden = YES;
    }
}

- (NSString*)imageNameForCellStyleModel:(CellStyleModel *)model
{
    switch (model.cellStyleType) {
        case CellStyleTypeLength:
            return @"icon_measure";
        case CellStyleTypeMoney:
            return @"icon_money";
        case CellStyleTypePhoto:
            return @"icon_photo";
        case CellStyleTypeText:
            return @"icon_text";
        case CellStyleTypeMass:
            return @"icon_weight";
        default:
            break;
    }
    return nil;
}

- (void)updateTags:(NSArray *)tags
{
    [self.tagContainer.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    int offset = 0;
    for(NSString *tag in tags)
    {
        TagView *tagView = [[TagView alloc] initWithText:tag];
        CGRect frame = tagView.frame;
        frame.origin.x = offset;
        offset+=frame.size.width + 4;
        tagView.frame = frame;
        [self.tagContainer addSubview:tagView];
    }
}

@end

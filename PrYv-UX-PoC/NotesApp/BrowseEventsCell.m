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
    [self layoutForCellStyleModel:cellStyleModel];
    self.iconImageView.image = [UIImage imageNamed:[self imageNameForCellStyleModel:cellStyleModel]];
}

- (void)layoutForCellStyleModel:(CellStyleModel *)model
{
    if(model.cellStyleSize == CellStyleSizeBig)
    {
        self.channelFolderLabel.frame = CGRectMake(72, 2, 320 - 79, 30);
        self.valueLabel.frame = CGRectMake(72, 36, 320 - 79, 24);
        self.tagContainer.frame = CGRectMake(72, 72, 320 - 79, 16);
        self.valueLabel.hidden = NO;
    }
    else
    {
        self.channelFolderLabel.frame = CGRectMake(72, 8, 320 - 80 - 16, 24);
        self.valueLabel.frame = CGRectMake(72, 36, 320 - 80 - 16, 24);
        self.tagContainer.frame = CGRectMake(72, 48, 320 - 80 - 16, 16);
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
        TagView *tagView = [[TagView alloc] initWithText:tag andStyle:TagViewStandardStyle];
        CGRect frame = tagView.frame;
        frame.origin.x = offset;
        offset+=frame.size.width + 4;
        tagView.frame = frame;
        [self.tagContainer addSubview:tagView];
    }
}

@end

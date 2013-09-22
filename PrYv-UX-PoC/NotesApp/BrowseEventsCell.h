//
//  BrowseEventsCell.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CellStyleModel;

@interface BrowseEventsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *channelFolderLabel;
@property (nonatomic, strong) IBOutlet UILabel *valueLabel;
@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;

- (void)updateWithCellStyleModel:(CellStyleModel*)cellStyleModel;
- (void)updateTags:(NSArray*)tags;

@end

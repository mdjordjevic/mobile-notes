//
//  GroupCell.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/2/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

@protocol GroupCellDataSource <NSObject>

- (NSInteger)numberOfItemsInGroupAtIndex:(NSInteger)groupIndex;
- (NSString*)titleForItemInGroupAtIndex:(NSInteger)groupIndex andItemIndex:(NSInteger)itemIndex;

@end

@interface GroupCell : PSTCollectionViewCell

@property (nonatomic) NSInteger cellIndex;
@property (nonatomic, strong) NSString *cellTitle;
@property (nonatomic, weak) id<GroupCellDataSource> dataSource;

- (void)updateItems;

@end

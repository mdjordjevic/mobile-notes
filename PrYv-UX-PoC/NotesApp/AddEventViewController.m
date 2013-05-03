//
//  AddEventViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "AddEventViewController.h"
#import "AddEventCell.h"
#import "Event.h"

@interface AddEventViewController ()

@property (nonatomic, strong) NSMutableArray *allEvents;

- (void)populateDummyData;

@end

@implementation AddEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self populateDummyData];
	[self.collectionView registerClass:[AddEventCell class] forCellWithReuseIdentifier:@"AddEventCell_ID"];
}

- (void)populateDummyData {
    self.allEvents = [NSMutableArray array];
    for(int i=0;i<16;i++) {
        Event *event = [[Event alloc] init];
        [event setEventName:[NSString stringWithFormat:@"%d",i]];
        [_allEvents addObject:event];
    }
}

#pragma mark - PSTCollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [_allEvents count];
}

#pragma mark - PSTCollectionViewDelegate

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AddEventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddEventCell_ID" forIndexPath:indexPath];
    [cell setCellTitle:[[_allEvents objectAtIndex:indexPath.row] valueForKeyPath:@"eventName"]];
    return (PSUICollectionViewCell*)cell;
}

#pragma mark - PSTCollectionViewDelegateFlowLayout

- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(60, 60);
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UIEdgeInsets)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

@end

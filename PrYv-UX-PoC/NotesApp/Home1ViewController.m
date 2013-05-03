//
//  Home1ViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "Home1ViewController.h"
#import "GroupCell.h"
#import <PryvApiKit/PryvApiKit.h>

@interface Home1ViewController ()

@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIImageView *plusIcon;

- (void)listAllChannels;
- (void)setupUI;
- (void)addButtonTouched:(id)sender;

@end

@implementation Home1ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.titles = [NSMutableArray array];
    [self listAllChannels];
    [self.collectionView registerClass:[GroupCell class] forCellWithReuseIdentifier:@"GroupCell_ID"];
    [self.collectionView setHeight:self.view.bounds.size.height - 100];
    [self setupUI];
}

- (void)setupUI {
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addButton setWidth:52];
    [_addButton setHeight:52];
    _addButton.center = CGPointMake(160, 360);
    UIImage *backgroundImage = [UIImage imageNamed:@"bg-addbutton"];
    UIImage *plusImage = [UIImage imageNamed:@"icon-plus"];
    self.plusIcon = [[UIImageView alloc] initWithImage:plusImage];
    _plusIcon.center = CGPointMake(26, 26);
    [_addButton setImage:backgroundImage forState:UIControlStateNormal];
    [_addButton addSubview:_plusIcon];
    [_addButton addTarget:self action:@selector(addButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addButton];
}

- (void)addButtonTouched:(id)sender {
    CGAffineTransform transform = CGAffineTransformIdentity;
    if(CGAffineTransformIsIdentity(_plusIcon.transform)) {
        transform = CGAffineTransformMakeRotation(-M_PI_4);
    }
    [UIView animateWithDuration:0.2 animations:^{
        _plusIcon.transform = transform;
    }];
}

#pragma mark - PSTCollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [_titles count];
}

#pragma mark - PSTCollectionViewDelegate

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupCell_ID" forIndexPath:indexPath];
    [cell setCellTitle:[_titles objectAtIndex:indexPath.row]];
    return cell;
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

- (void)listAllChannels {
    PYAccess *access = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:@"Ve69mGqqX5"];
    [access getChannelsWithRequestType:PYRequestTypeAsync filterParams:nil successHandler:^(NSArray *channelList) {
        for (PYChannel *channel in channelList)
        {
            if([_titles count] < 12) {
                [_titles addObject:channel.channelId];
            } else {
                break;
            }
        }
        [self.collectionView reloadData];
    } errorHandler:^(NSError *error) {
        
    }];
}

@end

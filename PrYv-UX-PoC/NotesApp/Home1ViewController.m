//
//  Home1ViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "Home1ViewController.h"
#import "AddEventViewController.h"
#import "DataGroupingManager.h"

@interface Home1ViewController ()

@property (nonatomic, strong) id<DataGroupingDataSource> groupingManager;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIImageView *plusIcon;
@property (nonatomic, strong) AddEventViewController *addEventVC;

- (void)setupUI;
- (void)addButtonTouched:(id)sender;
- (void)appDidReceiveAccessTokenNotification:(NSNotification*)notification;
- (void)showAddEventView:(BOOL)show;

@end

@implementation Home1ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.groupingManager = [DataGroupingManager channelGroupingManager];
    [self.collectionView registerClass:[GroupCell class] forCellWithReuseIdentifier:@"GroupCell_ID"];
    [self.collectionView setHeight:self.view.bounds.size.height - 100];
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidReceiveAccessTokenNotification:)
                                                 name:kAppDidReceiveAccessTokenNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [kSlidingController initSignIn];
}

- (void)setupUI
{
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addButton setWidth:52];
    [_addButton setHeight:52];
    _addButton.center = isiPhone5 ? CGPointMake(160, 460) : CGPointMake(160, 360);
    UIImage *backgroundImage = [UIImage imageNamed:@"bg-addbutton"];
    UIImage *plusImage = [UIImage imageNamed:@"icon-plus"];
    self.plusIcon = [[UIImageView alloc] initWithImage:plusImage];
    _plusIcon.center = CGPointMake(26, 26);
    [_addButton setImage:backgroundImage forState:UIControlStateNormal];
    [_addButton addSubview:_plusIcon];
    [_addButton addTarget:self
                   action:@selector(addButtonTouched:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addButton];
}

- (void)addButtonTouched:(id)sender {
    BOOL shouldShowAddEventVC = NO;
    if(CGAffineTransformIsIdentity(_plusIcon.transform)) {
        shouldShowAddEventVC = YES;
    }
    [self showAddEventView:shouldShowAddEventVC];
}

- (void)showAddEventView:(BOOL)show {
    if(show) {
        self.addEventVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"AddEventViewController_ID"];
        [_addEventVC.view setFrame:self.view.bounds];
        [_addEventVC.view setY:self.view.bounds.size.height];
        [self.view addSubview:_addEventVC.view];
        [UIView animateWithDuration:0.3f delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            _plusIcon.transform = CGAffineTransformMakeRotation(-M_PI_4);
            _addButton.center = CGPointMake(160, 60);
            [_addEventVC.view setY:100];
            CGFloat moveY = isiPhone5 ? -450 : -350;
            [self.collectionView moveVerticalBy:moveY];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:0.3f delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            _plusIcon.transform = CGAffineTransformIdentity;
            _addButton.center = isiPhone5 ? CGPointMake(160, 460) : CGPointMake(160, 360);
            [_addEventVC.view setY:self.view.bounds.size.height];
            CGFloat moveY = isiPhone5 ? 450 : 350;
            [self.collectionView moveVerticalBy:moveY];
        } completion:^(BOOL finished) {
            [_addEventVC.view removeFromSuperview];
            self.addEventVC = nil;
        }];
    }
}

#pragma mark - PSTCollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [_groupingManager numberOfGroups];
}

#pragma mark - PSTCollectionViewDelegate

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupCell_ID" forIndexPath:indexPath];
    [cell setCellTitle:[_groupingManager titleForGroupAtIndex:indexPath.row]];
    [cell setCellIndex:indexPath.row];
    [cell setDataSource:self];
    [cell updateItems];
    return (PSUICollectionViewCell*)cell;
}

#pragma mark - PSTCollectionViewDelegateFlowLayout

- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(93, 93);
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

#pragma mark - GroupCellDataSource

- (NSInteger)numberOfItemsInGroupAtIndex:(NSInteger)groupIndex {
    return [_groupingManager numberOfItemsInGroupAtIndex:groupIndex];
}

- (NSString*)titleForItemInGroupAtIndex:(NSInteger)groupIndex andItemIndex:(NSInteger)itemIndex {
    return [_groupingManager titleForItemInGroupAtIndex:groupIndex andItemIndex:itemIndex];
}

#pragma mark - Notifications

- (void)appDidReceiveAccessTokenNotification:(NSNotification *)notification {
    [_groupingManager performGroupingWithCompletionBlock:^{
        [[self collectionView] reloadData];
    }];
}


@end

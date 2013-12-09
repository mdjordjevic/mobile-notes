//
//  BaseDetailsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/2/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"

@class PYEvent;

@interface BaseDetailsViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIView *detailsContainerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dateButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *streamsSection;
@property (weak, nonatomic) IBOutlet UIView *tagsSection;

@property (nonatomic, strong) PYEvent *event;

- (void)updateDateFromPickerWith:(NSDate*)date;

@end

@protocol BaseDetailsDelegate <NSObject>


@end
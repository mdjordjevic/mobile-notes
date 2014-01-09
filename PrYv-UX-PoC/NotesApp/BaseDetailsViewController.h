//
//  BaseDetailsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/2/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"

@class PYEvent,JSTokenField;

@interface BaseDetailsViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIView *detailsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *streamsContainer;
@property (weak, nonatomic) IBOutlet UIView *tagsSection;
@property (weak, nonatomic) IBOutlet JSTokenField *tagsField;
@property (weak, nonatomic) IBOutlet UIButton *doneTagsEditingButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagsContainerConstraint;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;

@property (nonatomic, strong) PYEvent *event;
@property (nonatomic) BOOL isEditing;

- (void)updateDateFromPickerWith:(NSDate*)date;

@end

@protocol BaseDetailsDelegate <NSObject>

@optional

- (void)eventDidChangeProperties:(NSString*)valueClass valueType:(NSString*)valueType value:(NSString*)value;

@end
//
//  EventDetailsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/21/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "BaseDetailCell.h"
#import "PYEvent+Helper.h"
#import <PryvApiKit/PYEvent.h>
#import <PryvApiKit/PYEventType.h>

#define kValueCellHeight 100
#define kImageCellHeight 320

@interface EventDetailsViewController ()

@property (nonatomic) BOOL isStreamExpanded;
@property (nonatomic) BOOL isTagExpanded;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic) BOOL isInEditMode;

@property (nonatomic, strong) IBOutletCollection(BaseDetailCell) NSArray *cells;

@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic, weak) IBOutlet UILabel *streamsLabel;

@end

@implementation EventDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateUIForEvent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUIForEvent
{
    EventDataType eventDataType = [self.event eventDataType];
    if(eventDataType == EventDataTypeImage)
    {
        [self updateUIForEventImageType];
    }
    else if(eventDataType == EventDataTypeValueMeasure)
    {
        [self updateUIForValueEventType];
    }
    else if(eventDataType == EventDataTypeNote)
    {
        [self updateUIForNoteEventType];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.event.time];
    self.timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:date];
    self.streamsLabel.text = [self.event eventBreadcrumbsForStreamsList:self.streams];
    self.tagsLabel.text = [self.event.tags componentsJoinedByString:@", "];
}

- (void)updateUIForEventImageType
{
    if([self.event.attachments count] > 0)
    {
        PYAttachment *att = [self.event.attachments objectAtIndex:0];
        UIImage *img = [UIImage imageWithData:att.fileData];
        self.imageView.image = img;
    }
    self.descriptionLabel.text = self.event.eventDescription;
}

- (void)updateUIForValueEventType
{
    NSString *unit = [self.event.pyType symbol];
    if (! unit) { unit = self.event.pyType.formatKey ; }
    
    
    NSString *value = [NSString stringWithFormat:@"%@ %@",[self.event.eventContent description], unit];
    [self.valueLabel setText:value];
    
    NSString *formatDescription = [self.event.pyType localizedName];
    if (! formatDescription) { unit = self.event.pyType.key ; }
    [self.valueTypeLabel setText:formatDescription];
    self.descriptionLabel.text = self.event.eventDescription;
}

- (void)updateUIForNoteEventType
{
    self.descriptionLabel.text = self.event.eventContent;
}

#pragma mark - UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForCellAtIndexPath:indexPath withEvent:self.event];
}

#pragma mark - UITableViewDeleagate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Actions

- (IBAction)editButtonTouched:(id)sender
{
    self.isInEditMode = !self.isInEditMode;
    self.editButton.title = self.isInEditMode ? @"Done" : @"Edit";
    [self.cells enumerateObjectsUsingBlock:^(BaseDetailCell *cell, NSUInteger idx, BOOL *stop) {
        [cell setIsInEditMode:self.isInEditMode];
    }];
}

#pragma mark - Utils

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath withEvent:(PYEvent*)event
{
    EventDataType eventDataType = [event eventDataType];
    if(indexPath.row == 0)
    {
        if(eventDataType == EventDataTypeValueMeasure)
        {
            return kValueCellHeight;
        }
        return 0;
    }
    if(indexPath.row == 1)
    {
        if(eventDataType == EventDataTypeImage)
        {
            return kImageCellHeight;
        }
        return 0;
    }
    if(indexPath.row == 3)
    {
        if([self.descriptionLabel.text length] == 0)
        {
            return 0;
        }
        CGSize textSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(300, FLT_MAX)];
        CGFloat height = textSize.height + 10;
        return fmaxf(height, 54);
    }
    return 54;
}

@end

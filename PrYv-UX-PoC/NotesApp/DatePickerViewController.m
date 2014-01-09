//
//  DatePickerViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/8/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "DatePickerViewController.h"
#import "BaseDetailsViewController.h"

@interface DatePickerViewController ()

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@property (nonatomic, weak) BaseDetailsViewController *myBaseDetailsVC;

@end

@implementation DatePickerViewController

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
   }

- (void) setBaseDetailsVC:(BaseDetailsViewController*) baseDetailsVC
{
    self.myBaseDetailsVC = baseDetailsVC;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.myBaseDetailsVC.event.time];
	[self.datePicker setDate:date animated:NO];
    [self datePickerDidChangeDate:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonTouched:(id)sender
{
    [self.myBaseDetailsVC updateDateFromPickerWith:self.datePicker.date];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)datePickerDidChangeDate:(id)sender
{
    self.dateLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:self.datePicker.date];
}

@end

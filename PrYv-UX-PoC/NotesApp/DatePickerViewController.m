//
//  DatePickerViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/8/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController ()

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

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
    
	[self.datePicker setDate:self.selectedDate animated:NO];
    [self datePickerDidChangeDate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonTouched:(id)sender
{
    if(self.dateDidChangeBlock)
    {
        self.dateDidChangeBlock(self.datePicker.date,self);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)datePickerDidChangeDate:(id)sender
{
    self.dateLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:self.datePicker.date];
}

@end

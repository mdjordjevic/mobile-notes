//
//  ValueDetailsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ValueDetailsViewController.h"
#import "AddNumericalValueViewController.h"

@interface ValueDetailsViewController ()

@end

@implementation ValueDetailsViewController

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
	[self.eventValueLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventValueLabelTouched:)];
    [self.eventValueLabel addGestureRecognizer:tapGR];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateEventDetails
{
    if(self.isEditing || self.event.eventContent)
    {
        NSArray *components = [self.event.type componentsSeparatedByString:@"/"];
        if([components count] > 1)
        {
            NSString *value = [NSString stringWithFormat:@"%@ %@",[self.event.eventContent description],[components objectAtIndex:1]];
            self.eventValueLabel.text = value;
        }
        self.eventDescriptionLabel.text = self.event.eventDescription;
    }
    else
    {
        self.eventDescriptionLabel.text = NSLocalizedString(@"ViewController.TextContent.TapToAdd", nil);
        self.eventValueLabel.text = NSLocalizedString(@"ViewController.TextContent.TapToAdd", nil);
    }
}

- (void)eventValueLabelTouched:(id)sender
{
    AddNumericalValueViewController *addVC = (AddNumericalValueViewController *)[[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"AddNumericalValueViewController_ID"];
    if(self.event.type)
    {
        NSArray *components = [self.event.type componentsSeparatedByString:@"/"];
        if([components count] > 1)
        {
            addVC.value = [self.event.eventContent description];
            addVC.valueClass = [components objectAtIndex:0];
            addVC.valueType = [components objectAtIndex:1];
        }
    }
    
    addVC.delegate = self.delegate;
    [self.parentViewController.navigationController pushViewController:addVC animated:YES];
}

@end

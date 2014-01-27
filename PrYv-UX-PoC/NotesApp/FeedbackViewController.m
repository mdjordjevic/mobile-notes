//
//  FeedbackViewController.m
//  NotesApp
//
//  Created by Perki on 27.01.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "FeedbackViewController.h"
#import "TestFlight.h"

@interface FeedbackViewController ()

@property (nonatomic, strong) IBOutlet UITextView *feedbackTextView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton;

@end

@implementation FeedbackViewController

- (IBAction)sendButtonEventTouchUpInside:(UIBarButtonItem *)sender
{
    // Send feedback
    [TestFlight submitFeedback:self.feedbackTextView.text];
    
    // Alert user for successful sending
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FeedbackViewController.sentTitle", nil)
                                message:NSLocalizedString(@"FeedbackViewController.sentMessage", nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"FeedbackViewController.ok", nil) otherButtonTitles:nil] show];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [TestFlight passCheckpoint:@"Shown feedback entry"];
    self.feedbackTextView.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

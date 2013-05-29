//
//  EditEventViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/29/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "EditEventViewController.h"

@interface EditEventViewController ()

@property (nonatomic, strong) IBOutlet UIView *eventPreviewContainer;

@end

@implementation EditEventViewController

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
	
    CGRect previewFrame = CGRectMake(10, 10, 300, 100);
    UIView *previewView = [_eventElement elementPreviewViewForFrame:previewFrame];
    [self.eventPreviewContainer addSubview:previewView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  BaseContentViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/8/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseContentViewController.h"

@interface BaseContentViewController ()

@end

@implementation BaseContentViewController

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
	
    [self updateEventDetails];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateEventDetails
{
    
}

@end

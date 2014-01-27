//
//  TextEditorViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "TextEditorViewController.h"

@interface TextEditorViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;

@end

@implementation TextEditorViewController

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
    self.textView.text = self.text;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonTouched:(id)sender
{
    if (self.textDidChangeCallBack) {
        self.textDidChangeCallBack(self.textView.text, self);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end

//
//  NoteDetailsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "NoteDetailsViewController.h"
#import "TextEditorViewController.h"

@interface NoteDetailsViewController () <TextEditorDelegate>

@end

@implementation NoteDetailsViewController

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
	
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editDescriptionText:)];
    UIView *tapGesturePlaceholder = [[UIView alloc] initWithFrame:self.eventDescriptionLabel.frame];
    [tapGesturePlaceholder addGestureRecognizer:tapGR];
    [self.eventDescriptionLabel.superview addSubview:tapGesturePlaceholder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateEventDetails
{
    self.eventDescriptionLabel.text = self.event.eventContent;
}

- (void)editDescriptionText:(id)sender
{
    TextEditorViewController *textEditVC = (TextEditorViewController *)[[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"TextEditorViewController_ID"];
    textEditVC.delegate = self;
    textEditVC.text = self.event.eventContent;
    [self.parentViewController.navigationController pushViewController:textEditVC animated:YES];
}

#pragma mark - TextEditorDelegate Methods

- (void)textDidChangedTo:(NSString *)text forTextEditor:(TextEditorViewController *)textEditor
{
    self.eventDescriptionLabel.text = text;
    [self.delegate textDidChangedTo:text];
}

@end

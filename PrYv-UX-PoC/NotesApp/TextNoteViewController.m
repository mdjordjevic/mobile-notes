//
//  TextNoteViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "TextNoteViewController.h"
#import "DALinedTextView.h"
#import "TextNotePreviewElement.h"
#import "UserHistoryEntry.h"

#define kTextNoteSaveSegue_ID @"TextNoteSaveSegue_ID"

@interface TextNoteViewController ()

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

- (void)doneButtonTouched:(id)sender;
- (TextNotePreviewElement*)previewElement;

@end

@implementation TextNoteViewController

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
	
    self.doneButton = [UIBarButtonItem flatBarItemWithImage:[[UIImage imageNamed:@"navbar_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 4, 14, 4)] text:@"Post" target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    [[self.view.subviews objectAtIndex:0] removeFromSuperview];
    
    [self addCustomBackButton];
    
    if(self.event)
    {
        self.textView.text = self.event.eventContent;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (TextNotePreviewElement*)previewElement
{
    TextNotePreviewElement *element = [[TextNotePreviewElement alloc] init];
    element.textValue = self.textView.text;
    
    return element;
}

#pragma mark - Segues

- (void)doneButtonTouched:(id)sender
{
    [self performSegueWithIdentifier:kTextNoteSaveSegue_ID sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kTextNoteSaveSegue_ID])
    {
        /**
        EditEventViewController *editEventVC = (EditEventViewController*)[segue destinationViewController];
        TextNotePreviewElement *previewElement = [self previewElement];
        editEventVC.eventElement = previewElement;
        editEventVC.entry = self.entry;
        editEventVC.event = self.event; **/
    }
}

@end

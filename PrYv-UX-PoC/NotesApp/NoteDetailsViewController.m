//
//  NoteDetailsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "NoteDetailsViewController.h"
#import "TextEditorViewController.h"

@interface NoteDetailsViewController ()

- (BOOL) isEditable;

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
	if ([self isEditable]) {
        
        self.eventNoteContentLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editContentText:)];
        [self.eventNoteContentLabel addGestureRecognizer:tapGR];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isEditable
{
    return ([self.event.type isEqualToString:@"note/txt"] || [self.event.eventContent isKindOfClass:[NSString class]]);
}

- (void)updateEventDetails
{
    NSString *text = [NSString stringWithFormat:@"%@", self.event.eventContent];
    
    if(self.isEditing || [text length] > 0)
    {
        self.eventNoteContentLabel.text = text;
    }
    else
    {
        if ([self isEditable]) {
            self.eventNoteContentLabel.text = NSLocalizedString(@"ViewController.TextContent.TapToAdd", nil);
        } else {
            self.eventNoteContentLabel.text = @"";
        }
    }
}

- (void)editContentText:(id)sender
{
    if (! [self isEditable]) {
        NSLog(@"<WARNING> NoteDetailsViewController.editContentText: Cannot edit this kind of event: %@", self.event.type);
        return;
    }
    
    TextEditorViewController *textEditVC = (TextEditorViewController *)[[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"TextEditorViewController_ID"];
    if(self.isEditing)
    {
        textEditVC.text = self.event.eventContent;
    }
    else
    {
        textEditVC.text = NSLocalizedString(@"ViewController.TextContent.TapToAdd", nil);
    }
    [self.parentViewController.navigationController pushViewController:textEditVC animated:YES];
}


@end

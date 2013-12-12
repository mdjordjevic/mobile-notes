//
//  ImageDetailsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ImageDetailsViewController.h"
#import "ImagePreviewViewController.h"

@interface ImageDetailsViewController ()

@end

@implementation ImageDetailsViewController

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
	
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImagePreview:)];
    self.eventImage.userInteractionEnabled = YES;
    [self.eventImage addGestureRecognizer:tapGR];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showImagePreview:(id)sender
{
    ImagePreviewViewController *imagePreviewVC = (ImagePreviewViewController *)[[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"ImagePreviewViewController_ID"];
    imagePreviewVC.image = self.eventImage.image;
    imagePreviewVC.descText = self.eventDescriptionLabel.text;
    [self.navigationController pushViewController:imagePreviewVC animated:YES];
}

- (void)updateEventDetails
{
    PYAttachment *att = [self.event.attachments objectAtIndex:0];
    UIImage *img = [UIImage imageWithData:att.fileData];
    self.eventImage.image = img;
    self.eventDescriptionLabel.text = self.event.eventDescription;
}

@end

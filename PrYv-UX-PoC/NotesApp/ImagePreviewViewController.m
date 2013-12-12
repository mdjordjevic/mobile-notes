//
//  ImagePreviewViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/12/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ImagePreviewViewController.h"

@interface ImagePreviewViewController () <UIScrollViewDelegate>

@end

@implementation ImagePreviewViewController

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
    
	[self.scrollView setZoomScale:self.scrollView.minimumZoomScale];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar:)];
    tapGR.numberOfTapsRequired = 1;
    tapGR.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:tapGR];
    
    [self setupViewForImage:self.image];
    self.descriptionText.text = self.descText;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 4.0f;
    self.scrollView.zoomScale = 1.0f;
    
    [self centerScrollViewContents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleNavigationBar:(id)sender
{
    BOOL showViews = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:!showViews animated:YES];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if(showViews)
        {
            CGRect frame = self.descriptionText.frame;
            frame.origin.y = self.view.bounds.size.height - 167;
            self.descriptionText.frame = frame;
        }
        else
        {
            CGRect frame = self.descriptionText.frame;
            frame.origin.y = self.view.bounds.size.height;
            self.descriptionText.frame = frame;
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setupViewForImage:(UIImage *)image
{
    self.contentImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.contentImageView.image = image;
    self.scrollView.contentSize = self.contentImageView.frame.size;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
    return self.contentImageView;
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.contentImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.contentImageView.frame = contentsFrame;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}

#pragma mark - Actions

- (IBAction)closeButtonTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
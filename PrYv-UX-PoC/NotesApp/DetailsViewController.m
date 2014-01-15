//
//  DetailsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/22/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "DetailsViewController.h"
#import "CellStyleModel.h"
#import "DataService.h"
#import "AddNumericalValueViewController.h"
#import "TextNoteViewController.h"
#import "UIAlertView+PrYv.h"
#import "PYEvent+Helper.h"

#define kEditEventSegue_ID @"EditEventSegue_ID"
#define kAddTextNoteSegue_ID @"AddTextNoteSegue_ID"
#define kAddTypeSegue_ID @"AddTypeSegue_ID"

@interface DetailsViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *streamLabel;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *value;
@property (nonatomic) CellStyleType eventType;

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView;
- (void)setupDetailsForImage:(UIImage*)image;
- (void)editButtonTouched:(id)sender;
- (IBAction)deleteButtonTouched:(id)sender;

@end

@implementation DetailsViewController

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
	
    [self addCustomBackButton];
    UIBarButtonItem *editButton = [UIBarButtonItem flatBarItemWithImage:[[UIImage imageNamed:@"navbar_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 4, 14, 4)] text:@"Edit" target:self action:@selector(editButtonTouched:)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    self.eventType = [[DataService sharedInstance] cellStyleForEvent:self.event];
    self.streamLabel.hidden = YES;
    [[DataService sharedInstance] fetchAllStreamsWithCompletionBlock:^(id object, NSError *error) {
        self.streamLabel.text = [self.event eventBreadcrumbsForStreamsList:object];
        self.streamLabel.hidden = NO;
    }];
    [[self.view.subviews objectAtIndex:0] removeFromSuperview];
    if(self.eventType == CellStyleTypePhoto)
    {
        PYAttachment *att = [self.event.attachments objectAtIndex:0];
        UIImage *img = [UIImage imageWithData:att.fileData];
        [self setupDetailsForImage:img];
        self.textView.hidden = YES;
        self.scrollView.frame = CGRectMake(0, 40, 320, self.view.bounds.size.height - 40);
        self.imageView.frame = [self centeredFrameForScrollView:self.scrollView andUIView:self.imageView];
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale];
        self.value.hidden = YES;
    }
    else if(self.eventType == CellStyleTypeText)
    {
        self.textView.hidden = NO;
        self.textView.editable = NO;
        self.textView.text = self.event.eventContent;
        self.scrollView.hidden = YES;
        self.textView.frame = CGRectMake(0, 40, 320, self.view.bounds.size.height - 40);
        self.value.hidden = YES;
    }
    else
    {
        self.textView.hidden = YES;
        self.scrollView.hidden = YES;
        NSArray *components = [self.event.type componentsSeparatedByString:@"/"];
        if([components count] > 1)
        {
            NSString *value = [NSString stringWithFormat:@"%@ %@",[self.event.eventContent description],[components objectAtIndex:1]];
            self.value.text = value;
            self.value.hidden = NO;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)editButtonTouched:(id)sender
{
    if(self.eventType == CellStyleTypePhoto)
    {
        [self performSegueWithIdentifier:kEditEventSegue_ID sender:self];
    }
    else if(self.eventType == CellStyleTypeText)
    {
        [self performSegueWithIdentifier:kAddTextNoteSegue_ID sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:kAddTypeSegue_ID sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kAddTextNoteSegue_ID])
    {
        TextNoteViewController *textVC = (TextNoteViewController*)segue.destinationViewController;
        textVC.event = self.event;
    }
    else if([segue.identifier isEqualToString:kAddTypeSegue_ID])
    {
        AddNumericalValueViewController *addVC = (AddNumericalValueViewController*)segue.destinationViewController;
    }
}

#pragma mark - Image scrolling

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
    return self.imageView;
}

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView
{
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    if(frameToCenter.size.width < boundsSize.width)
    {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else
    {
        frameToCenter.origin.x = 0;
    }
    if(frameToCenter.size.height < boundsSize.height)
    {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else
    {
        frameToCenter.origin.y = 0;
    }
    return frameToCenter;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.imageView.frame = [self centeredFrameForScrollView:self.scrollView andUIView:self.imageView];
}

- (void)setupDetailsForImage:(UIImage *)image
{
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.imageView.image = image;
    self.scrollView.minimumZoomScale = self.scrollView.frame.size.width / self.imageView.frame.size.width;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.contentSize = self.imageView.frame.size;
}

#pragma mark - Actions

- (void)deleteButtonTouched:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete this event?" message:nil delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView showWithCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(alertView.cancelButtonIndex != buttonIndex)
        {
            [self showLoadingOverlay];
            
            
            [NotesAppController sharedConnectionWithID:nil noConnectionCompletionBlock:nil withCompletionBlock:^(PYConnection *connection)
             {
                 [connection trashOrDeleteEvent:self.event withRequestType:PYRequestTypeAsync successHandler:^{
                     [self.navigationController dismissViewControllerAnimated:YES completion:^{
                         [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
                     }];
                 } errorHandler:^(NSError *error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                     [alert show];
                 }];
                 
             }];
        }
    }];
}

@end

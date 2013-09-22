//
//  PhotoNoteViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PhotoNoteViewController.h"
#import "EditEventViewController.h"
#import "PhotoPreviewElement.h"
#import "UIImage+PrYv.h"

#define kSaveImageSegue_ID @"SaveImageSegue_ID"

@interface PhotoNoteViewController ()

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *selectedImage;

- (void)setupImagePicker;
- (PhotoPreviewElement*)previewElement;

@end

@implementation PhotoNoteViewController

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
    [self setupImagePicker];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.imagePicker.isBeingDismissed)
    {
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupImagePicker
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else
    {
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePicker.showsCameraControls = YES;
    }
    _imagePicker.delegate = self;
    
}


- (PhotoPreviewElement*)previewElement
{
    PhotoPreviewElement *pElement = [[PhotoPreviewElement alloc] init];
    pElement.previewImage = self.selectedImage;
    return pElement;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    CGSize newSize = self.selectedImage.size;
    CGFloat maxSide = MAX(newSize.width, newSize.height);
    CGFloat ratio = maxSide / 1024.0f;
    newSize = CGSizeMake(floorf(newSize.width/ratio), floorf(newSize.height/ratio));
    self.selectedImage = [self.selectedImage imageScaledToSize:newSize];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self performSegueWithIdentifier:kSaveImageSegue_ID sender:self];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self popViewController];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kSaveImageSegue_ID])
    {
        EditEventViewController *editEventVC = (EditEventViewController*)[segue destinationViewController];
        PhotoPreviewElement *previewElement = [self previewElement];
        editEventVC.eventElement = previewElement;
        editEventVC.entry = self.entry;
    }
}

@end

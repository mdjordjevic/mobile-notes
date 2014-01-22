//
//  PhotoNoteViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PhotoNoteViewController.h"
#import "UIImage+PrYv.h"
#import "BrowseEventsViewController.h"

#define kSaveImageSegue_ID @"SaveImageSegue_ID"

@interface PhotoNoteViewController ()

@property (nonatomic, strong) UIImagePickerController *imagePicker;

- (void)setupImagePicker;

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
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&  self.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    _imagePicker.sourceType = self.sourceType;
    if(_imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        _imagePicker.showsCameraControls = YES;
    }
    _imagePicker.delegate = self;
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    CGSize newSize = selectedImage.size;
    CGFloat maxSide = MAX(newSize.width, newSize.height);
    CGFloat ratio = maxSide / 1024.0f;
    newSize = CGSizeMake(floorf(newSize.width/ratio), floorf(newSize.height/ratio));
    selectedImage = [selectedImage imageScaledToSize:newSize];
    [self dismissViewControllerAnimated:YES completion:^{
        [self popViewController];
        self.browseVC.pickedImage = selectedImage;
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self popViewController];
}

@end

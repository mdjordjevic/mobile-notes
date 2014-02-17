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
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

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

- (UIImage*)scaledImageForImage:(UIImage*)image
{
    CGSize newSize = image.size;
    CGFloat maxSide = MAX(newSize.width, newSize.height);
    CGFloat ratio = maxSide / 1024.0f;
    newSize = CGSizeMake(floorf(newSize.width/ratio), floorf(newSize.height/ratio));
    return [image imageScaledToSize:newSize];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    selectedImage = [self scaledImageForImage:selectedImage];
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    ALAssetsLibrary *aLib = [[ALAssetsLibrary alloc] init];
    [aLib assetForURL:imageURL resultBlock:^(ALAsset *asset) {
        NSDictionary *metadata = asset.defaultRepresentation.metadata;
        NSDate *date = nil;
        if(metadata)
        {
            NSString *timeString = [[metadata objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"];
            if(timeString)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
                date = [dateFormatter dateFromString:timeString];
                
            }
        }
        [self dismissViewControllerAnimated:YES completion:^{
            [self popViewController];
            self.browseVC.pickedImageTimestamp = date;
            self.browseVC.pickedImage = selectedImage;
        }];
    } failureBlock:^(NSError *error) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self popViewController];
            self.browseVC.pickedImage = selectedImage;
        }];
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self popViewController];
}

@end

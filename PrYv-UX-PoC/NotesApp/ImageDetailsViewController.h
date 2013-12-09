//
//  ImageDetailsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseContentViewController.h"

@interface ImageDetailsViewController : BaseContentViewController

@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;

@end

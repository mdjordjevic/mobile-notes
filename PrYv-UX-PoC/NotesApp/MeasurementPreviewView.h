//
//  MeasurementPreviewView.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 6/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeasurementPreviewView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *classImage;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet UITextField *tagsField;
@property (nonatomic, strong) IBOutlet UIView *tagsContainer;

@end

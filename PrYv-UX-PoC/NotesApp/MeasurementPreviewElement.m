//
//  MeasurementPreviewElement.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/29/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "MeasurementPreviewElement.h"
#import "MeasurementPreviewView.h"
#import <QuartzCore/QuartzCore.h>

@interface MeasurementPreviewElement ()

@property (nonatomic, strong) MeasurementPreviewView *view;

@end

@implementation MeasurementPreviewElement

- (UIView*)elementPreviewViewForFrame:(CGRect)frame
{
    self.view.frame = frame;
    return self.view;
}

- (MeasurementPreviewView*)view
{
    if(!_view)
    {
        _view = [[MeasurementPreviewView alloc] initWithFrame:CGRectZero];
        _view.backgroundView.layer.cornerRadius = 6;
        _view.tagsContainer.layer.cornerRadius = 6;
        _view.classImage.image = [UIImage imageNamed:self.klass];
        _view.titleLabel.text = [NSString stringWithFormat:@"%@ %@",self.value,self.format];
        NSString *descText = @"";
        if(self.channelName)
        {
            if(self.folderName)
            {
                descText = [NSString stringWithFormat:@"%@, %@",self.channelName,self.folderName];
            }
            else
            {
                descText = self.channelName;
            }
        }
        _view.descriptionLabel.text = descText;
    }
    return _view;
}

- (NSString*)elementTitle
{
    return @"Numerical value";
}

- (void)updateDescriptionWithText:(NSString *)text
{
    self.view.descriptionLabel.text = text;
}

- (UITextField*)tagsLabel
{
    return self.view.tagsField;
}


@end

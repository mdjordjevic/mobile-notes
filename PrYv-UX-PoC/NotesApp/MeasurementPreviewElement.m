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
        _view.classImage.image = [UIImage imageNamed:_klass];
        _view.titleLabel.text = [NSString stringWithFormat:@"%@ %@",_value,_format];
        NSString *descText = @"";
        if(_channelName)
        {
            if(_folderName)
            {
                descText = [NSString stringWithFormat:@"%@, %@",_channelName,_folderName];
            }
            else
            {
                descText = _channelName;
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

//
//  MeasurementPreviewElement.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/29/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "MeasurementPreviewElement.h"

@implementation MeasurementPreviewElement

- (UIView*)elementPreviewViewForFrame:(CGRect)frame
{
    UIView *element = [[UIView alloc] initWithFrame:frame];
    [element setBackgroundColor:[UIColor whiteColor]];
    UIImageView *classImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    UIImage *classImage = [UIImage imageNamed:_klass];
    [classImageView setImage:classImage];
    [element addSubview:classImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 190, 30)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:16]];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setTextColor:[UIColor darkGrayColor]];
    [label setText:[NSString stringWithFormat:@"%@ %@",_value,_format]];
    [element addSubview:label];
    
    return element;
}


@end

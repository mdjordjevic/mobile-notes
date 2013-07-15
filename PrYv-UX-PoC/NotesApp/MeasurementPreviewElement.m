//
//  MeasurementPreviewElement.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/29/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "MeasurementPreviewElement.h"

@interface MeasurementPreviewElement ()

@end

@implementation MeasurementPreviewElement

- (UIImage*)elementPreviewImage
{
    return [UIImage imageNamed:self.klass];
}

- (NSString*)elementTitle
{
    return [NSString stringWithFormat:@"%@ %@",self.value,self.format];
}

- (NSString*)elementSubtitle
{
    return nil;
}


@end

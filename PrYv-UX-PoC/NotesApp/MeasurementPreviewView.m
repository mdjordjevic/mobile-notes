//
//  MeasurementPreviewView.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 6/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "MeasurementPreviewView.h"

@implementation MeasurementPreviewView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"MeasurementPreviewView"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        self.frame = frame;
    }
    return self;
}


@end

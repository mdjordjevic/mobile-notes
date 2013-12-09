//
//  ValueCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 10/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ValueCell.h"
#import <PryvApiKit/PYEvent.h>
#import <PryvApiKit/PYEventType.h>

@implementation ValueCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)updateWithEvent:(PYEvent *)event andListOfStreams:(NSArray *)streams
{
    NSString *unit = [event.pyType symbol];
    if (! unit) { unit = event.pyType.formatKey ; }
    
    
    NSString *value = [NSString stringWithFormat:@"%@ %@",[event.eventContent description], unit];
    [self.valueLabel setText:value];
    
    [super updateWithEvent:event andListOfStreams:streams];
}

@end

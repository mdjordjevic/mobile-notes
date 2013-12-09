//
//  ValueCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 10/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ValueCell.h"

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
    NSArray *components = [event.type componentsSeparatedByString:@"/"];
    if([components count] > 1)
    {
        NSString *value = [NSString stringWithFormat:@"%@ %@",[event.eventContent description],[components objectAtIndex:1]];
        [self.valueLabel setText:value];
    }
    [super updateWithEvent:event andListOfStreams:streams];
}

@end

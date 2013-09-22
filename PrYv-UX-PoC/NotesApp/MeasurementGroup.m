//
//  MeasurementGroup.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/26/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "MeasurementGroup.h"

@interface MeasurementGroup ()

@end

@implementation MeasurementGroup

- (id)initWithName:(NSString *)name andListOfTypes:(NSArray *)listOfTypes
{
    self = [super init];
    if(self)
    {
        self.name = name;
        self.types = listOfTypes;
    }
    return self;
}

@end

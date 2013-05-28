//
//  MeasurementType.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/26/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "MeasurementType.h"

@interface MeasurementType ()

@property (nonatomic, strong) NSDictionary *names;

@end

@implementation MeasurementType

- (id)initWithMark:(NSString *)mark andNames:(NSDictionary *)names
{
    self = [super init];
    if(self)
    {
        self.mark = mark;
        self.names = names;
    }
    return self;
}

- (NSString*)localizedName
{
    return [_names objectForKey:kLocalizedKey];
}

@end

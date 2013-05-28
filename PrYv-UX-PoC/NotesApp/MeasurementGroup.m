//
//  MeasurementGroup.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/26/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "MeasurementGroup.h"
#import "MeasurementType.h"

@interface MeasurementGroup ()

- (void)initMeasurementTypesWithListOfTypes:(NSArray*)listOfTypes withLocalizedNames:(NSDictionary*)localizedNames;

@end

@implementation MeasurementGroup

- (id)initWithName:(NSString *)name andListOfTypes:(NSArray *)listOfTypes andLocalizedNames:(NSDictionary *)localizedNames
{
    self = [super init];
    if(self)
    {
        self.name = name;
        self.types = [NSMutableArray array];
        [self initMeasurementTypesWithListOfTypes:listOfTypes withLocalizedNames:localizedNames];
    }
    return self;
}

- (void)initMeasurementTypesWithListOfTypes:(NSArray *)listOfTypes withLocalizedNames:(NSDictionary *)localizedNames
{
    for(NSString *mark in listOfTypes)
    {
        MeasurementType *type = [[MeasurementType alloc] initWithMark:mark andNames:[localizedNames objectForKey:mark]];
        [_types addObject:type];
    }
}

@end

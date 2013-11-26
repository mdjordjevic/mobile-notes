//
//  MeasurementSet.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "MeasurementSet.h"

@interface MeasurementSet ()

@property (nonatomic, copy) NSDictionary *names;
@property (nonatomic, copy) NSDictionary *descriptions;

- (void)initMeasurementTypesWithTypesDic:(NSDictionary*)types;

@end

@implementation MeasurementSet

- (id)initWithKey:(NSString *)key andDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(self)
    {
        self.key = key;
        self.names = [dictionary objectForKey:@"name"];
        self.descriptions = [dictionary objectForKey:@"description"];
        self.measurementGroups = [NSMutableArray array];
        [self initMeasurementTypesWithTypesDic:[dictionary objectForKey:@"types"]];
    }
    return self;
}

- (void)initMeasurementTypesWithTypesDic:(NSDictionary *)types
{
    for(NSString *groupName in [types allKeys])
    {
        MeasurementGroup *group = [[MeasurementGroup alloc] initWithName:groupName andListOfTypes:[types objectForKey:groupName]];
        [self.measurementGroups addObject:group];
    }
}

- (NSString*)localizedName
{
    if(self.names)
    {
        return [_names objectForKey:kLocalizedKey];
    }
    return self.key;
}

- (NSString*)localizedDescription
{
    if(self.descriptions)
    {
        return [_descriptions objectForKey:kLocalizedKey];
    } else {
        // TODO if no description, then
        return @"TODO should be some examles of measures...";
    }
    return self.key;
}

@end

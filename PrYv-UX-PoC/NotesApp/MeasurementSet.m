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

- (void)initMeasurementTypesWithTypesDic:(NSDictionary*)types andLocalizedNames:(NSDictionary*)localizedNames;

@end

@implementation MeasurementSet

- (id)initWithKey:(NSString *)key andDictionary:(NSDictionary *)dictionary andLocalizedNames:(NSDictionary *)localizedNames
{
    self = [super init];
    if(self)
    {
        self.key = key;
        self.names = [dictionary objectForKey:@"name"];
        self.descriptions = [dictionary objectForKey:@"description"];
        self.measurementGroups = [NSMutableArray array];
        [self initMeasurementTypesWithTypesDic:[dictionary objectForKey:@"types"] andLocalizedNames:localizedNames];
    }
    return self;
}

- (void)initMeasurementTypesWithTypesDic:(NSDictionary *)types andLocalizedNames:(NSDictionary *)localizedNames
{
    for(NSString *groupName in [types allKeys])
    {
        MeasurementGroup *group = [[MeasurementGroup alloc] initWithName:groupName andListOfTypes:[types objectForKey:groupName] andLocalizedNames:[localizedNames objectForKey:groupName]];
        [self.measurementGroups addObject:group];
    }
}

- (NSString*)localizedName
{
    return [_names objectForKey:kLocalizedKey];
}

- (NSString*)localizedDescription
{
    return [_descriptions objectForKey:kLocalizedKey];
}

@end

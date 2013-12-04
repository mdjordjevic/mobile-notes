//
//  MeasurementController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/27/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "MeasurementController.h"
#import "DataService.h"
#import <PryvApiKit/PYMeasurementSet.h>
#import <PryvApiKit/PYEventTypes.h>

#define kMeasurementSetsKey @"kMeasurementSetsKey"

@interface MeasurementController ()

@property (nonatomic, strong) NSMutableArray *userMeasurementSets;

- (void)initObject;
- (void)saveMeasurementSets;

@end

@implementation MeasurementController

+ (MeasurementController*)sharedInstance
{
    static MeasurementController *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MeasurementController alloc] init];
        [_sharedInstance initObject];
    });
    return _sharedInstance;
}

- (void)initObject
{
    [self loadUserMeasurementSets];
}

- (void)saveMeasurementSets
{
    [[NSUserDefaults standardUserDefaults] setObject:_userMeasurementSets forKey:kMeasurementSetsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)loadUserMeasurementSets
{
    self.userMeasurementSets = [[NSUserDefaults standardUserDefaults] objectForKey:kMeasurementSetsKey];
    if(!_userMeasurementSets)
    {
        self.userMeasurementSets = [NSMutableArray array];
    }
    
    if([_userMeasurementSets count] < 1)
    {
        [self addMeasurementSetWithKey:@"money-most-used"];
        
        if ([[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue]) { // ismetric
            [self addMeasurementSetWithKey:@"generic-measurements-metric"];
            
        } else {
            [self addMeasurementSetWithKey:@"generic-measurements-imperial"];
        }
        if ([[[NSLocale currentLocale] objectForKey:NSLocaleMeasurementSystem] isEqualToString:@"U.S."]) {
            [self addMeasurementSetWithKey:@"generic-measurements-us"];
        }
        
        if([_userMeasurementSets count] < 1)
        {
            PYMeasurementSet *set = [[[PYEventTypes sharedInstance] measurementSets] objectAtIndex:0];
            [_userMeasurementSets insertObject:[set key] atIndex:0];
        }
        
    }
 
}

#pragma mark - Public API

- (void)addMeasurementSetWithKey:(NSString*)key
{
    if(![_userMeasurementSets containsObject:key])
    {
        [_userMeasurementSets addObject:key];
        [self saveMeasurementSets];
    }
}

- (void)removeMeasurementSetWithKey:(NSString*)key
{
    [_userMeasurementSets removeObject:key];
    [self saveMeasurementSets];
}


- (NSArray*)userSelectedMeasurementSets
{
    return _userMeasurementSets;
}

@end

//
//  MeasurementController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/27/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "MeasurementController.h"
#import "DataService.h"
#import "MeasurementSet.h"

#define kMeasurementSetsKey @"kMeasurementSetsKey" 

@interface MeasurementController ()

@property (nonatomic, strong) NSMutableArray *measurementSets;
@property (nonatomic, strong) NSMutableArray *userMeasurementSets;

- (void)initObject;
- (void)saveMeasurementSets;
- (void)loadMeasurementSets;

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
    [self loadMeasurementSets];
}

- (void)saveMeasurementSets
{
    [[NSUserDefaults standardUserDefaults] setObject:_userMeasurementSets forKey:kMeasurementSetsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadMeasurementSets
{
    self.userMeasurementSets = [[NSUserDefaults standardUserDefaults] objectForKey:kMeasurementSetsKey];
    if(!_userMeasurementSets)
    {
        self.userMeasurementSets = [NSMutableArray array];
    }
    [DataService fetchAllMeasurementSetsWithCompletionBlock:^(id object, NSError *error) {
        if(!error)
        {
            self.measurementSets = (NSMutableArray*)object;
            if([_userMeasurementSets count] < 1)
            {
                MeasurementSet *set = [_measurementSets objectAtIndex:0];
                [_userMeasurementSets insertObject:[set key] atIndex:0];
            }
        }
        else
        {
            NSLog(@"Can't fetch measurement list: %@",error);
        }
    }];
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

- (NSArray*)availableMeasurementSets
{
    return _measurementSets;
}

- (NSArray*)userSelectedMeasurementSets
{
    return _userMeasurementSets;
}

@end

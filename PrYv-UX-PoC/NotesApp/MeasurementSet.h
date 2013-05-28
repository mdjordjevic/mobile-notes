//
//  MeasurementSet.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeasurementGroup.h"
#import "MeasurementType.h"

@interface MeasurementSet : NSObject

- (id)initWithKey:(NSString*)key andDictionary:(NSDictionary*)dictionary andLocalizedNames:(NSDictionary*)localizedNames;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, readonly) NSString *localizedName;
@property (nonatomic, readonly) NSString *localizedDescription;
@property (nonatomic, strong) NSMutableArray *measurementGroups;

@end

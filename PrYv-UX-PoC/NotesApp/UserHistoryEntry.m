//
//  UserHistoryEntry.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 6/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "UserHistoryEntry.h"

#define kStreamIdKey @"StreamID"
#define kTagsKey @"TagsKey"
#define kDataTypeKey @"DataType"
#define kMeasurementGroupNameKey @"MeasurementGroupNameKey"
#define kMeasurementTypeNameKey @"MeasurementTypeNameKey"

@implementation UserHistoryEntry

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:_streamId forKey:kStreamIdKey];
    [encoder encodeObject:_tags forKey:kTagsKey];
    [encoder encodeInteger:_dataType forKey:kDataTypeKey];
    [encoder encodeObject:_measurementGroupName forKey:kMeasurementGroupNameKey];
    [encoder encodeObject:_measurementTypeName forKey:kMeasurementTypeNameKey];
}

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self)
    {
        self.streamId = [decoder decodeObjectForKey:kStreamIdKey];
        self.tags = [decoder decodeObjectForKey:kTagsKey];
        self.dataType = [decoder decodeIntegerForKey:kDataTypeKey];
        self.measurementGroupName = [decoder decodeObjectForKey:kMeasurementGroupNameKey];
        self.measurementTypeName = [decoder decodeObjectForKey:kMeasurementTypeNameKey];
    }
    return self;
}

- (NSString*)comparableString
{
    NSArray *sortedTags = [self.tags sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableString *toReturn = [NSMutableString stringWithString:self.streamId];
    [toReturn appendFormat:@" %d",self.dataType];
    [toReturn appendString:[sortedTags componentsJoinedByString:@" "]];
    if(self.measurementGroupName)
    {
        [toReturn appendFormat:@" %@",self.measurementGroupName];
    }
    if(self.measurementTypeName)
    {
        [toReturn appendFormat:@" %@",self.measurementTypeName];
    }
    return toReturn;
}

@end

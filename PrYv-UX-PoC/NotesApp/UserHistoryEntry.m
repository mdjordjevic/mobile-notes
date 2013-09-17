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

@implementation UserHistoryEntry

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:_streamId forKey:kStreamIdKey];
    [encoder encodeObject:_tags forKey:kTagsKey];
    [encoder encodeInteger:_dataType forKey:kDataTypeKey];
}

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self)
    {
        self.streamId = [decoder decodeObjectForKey:kStreamIdKey];
        self.tags = [decoder decodeObjectForKey:kTagsKey];
        self.dataType = [decoder decodeIntegerForKey:kDataTypeKey];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    UserHistoryEntry *otherObject = (UserHistoryEntry*)object;
    BOOL equal = YES;
    equal = equal && [self.streamId isEqualToString:otherObject.streamId];
    equal = equal && self.dataType == otherObject.dataType;

    if([otherObject.tags count] != [self.tags count])
    {
        equal = NO;
    }
    else
    {
        NSMutableArray *diff = [NSMutableArray arrayWithArray:otherObject.tags];
        [diff removeObjectsInArray:self.tags];
        equal = equal && ([diff count] == 0);
    }
    return equal;
}

- (NSUInteger)hash
{
    NSUInteger tagsHash = 0;
    for(NSString* tag in self.tags)
    {
        tagsHash+=[tag hash];
    }
    return [self.streamId hash] + tagsHash + self.dataType;
}

@end

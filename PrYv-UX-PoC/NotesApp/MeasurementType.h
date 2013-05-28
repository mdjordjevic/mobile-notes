//
//  MeasurementType.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/26/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeasurementType : NSObject

@property (nonatomic, readonly) NSString *localizedName;
@property (nonatomic, strong) NSString *mark;

- (id)initWithMark:(NSString*)mark andNames:(NSDictionary*)names;

@end

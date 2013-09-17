//
//  MeasurementGroup.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/26/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeasurementGroup : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *types;

- (id)initWithName:(NSString*)name andListOfTypes:(NSArray*)listOfTypes;

@end

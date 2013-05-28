//
//  DataService.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "DataService.h"
#import <PryvApiKit/PYClient.h>
#import "MeasurementSet.h"

#define kMeasurementSetsUrl @"http://pryv.github.io/event-types/event-types-extras.json"

@implementation DataService

+ (void)fetchAllMeasurementSetsWithCompletionBlock:(FetchDataCompletionBlock)completionBlock
{
    NSURL *measurementSetsURL = [NSURL URLWithString:kMeasurementSetsUrl];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:measurementSetsURL];
    [PYClient sendRequest:request withReqType:PYRequestTypeSync success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *sets = [NSMutableArray array];
        NSDictionary *setsJSON = [JSON objectForKey:@"sets"];
        NSDictionary *localizedNamesJSON = [JSON objectForKey:@"localizedNames"];
        for(NSString *setKey in [setsJSON allKeys])
        {
            NSDictionary *setDic = [setsJSON objectForKey:setKey];
            MeasurementSet *set = [[MeasurementSet alloc] initWithKey:setKey andDictionary:setDic andLocalizedNames:localizedNamesJSON];
            [sets addObject:set];
        }
        if(completionBlock)
        {
            completionBlock(sets, nil);
        }
    } failure:^(NSError *error) {
        if(completionBlock)
        {
            completionBlock(nil, error);
        }
    }];
}

@end

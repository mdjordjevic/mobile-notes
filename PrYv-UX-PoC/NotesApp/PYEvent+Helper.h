//
//  PYEvent+Helper.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <PryvApiKit/PryvApiKit.h>

@interface PYEvent (Helper)

- (NSString*)eventBreadcrumbsForStreamsList:(NSArray*)streams;

- (EventDataType)eventDataType;
- (NSInteger)cellStyle;

- (void)firstAttachmentAsImage:(void (^) (UIImage *image))attachmentAsImage
             errorHandler:(void(^) (NSError *error))failure;

- (BOOL)hasFirstAttachmentFileDataInMemory ;

@end

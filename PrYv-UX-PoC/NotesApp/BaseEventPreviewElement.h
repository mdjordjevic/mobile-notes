//
//  BaseEventPreviewElement.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/29/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BaseEventPreviewElement <NSObject>

- (UIView*)elementPreviewViewForFrame:(CGRect)frame;
- (NSString*)elementTitle;
- (void)updateDescriptionWithText:(NSString*)text;
- (UITextField*)tagsLabel;

@end

@interface BaseEventPreviewElement : NSObject <BaseEventPreviewElement>

@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSString *klass;
@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *folderName;

@end

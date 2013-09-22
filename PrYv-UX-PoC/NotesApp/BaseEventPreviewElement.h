//
//  BaseEventPreviewElement.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/29/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PryvApiKit/PryvApiKit.h>

@protocol BaseEventPreviewElement <NSObject>

- (UIImage*)elementPreviewImage;
- (NSString*)elementTitle;
- (NSString*)elementSubtitle;

@end

@interface BaseEventPreviewElement : NSObject <BaseEventPreviewElement>

@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSString *klass;
@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) NSString *textValue;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, readonly) PYAttachment *attachment;

@end

//
//  BaseContentViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/8/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseDetailsViewController.h"
#import "PYEvent+Helper.h"

@interface BaseContentViewController : BaseViewController

@property (nonatomic, weak) id<BaseDetailsDelegate> delegate;
@property (nonatomic, weak) PYEvent *event;
@property (nonatomic) BOOL isEditing;

- (void)updateEventDetails;

@end

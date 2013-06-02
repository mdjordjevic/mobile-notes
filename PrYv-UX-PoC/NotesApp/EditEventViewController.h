//
//  EditEventViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/29/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseEventPreviewElement.h"
#import "Channel.h"
#import "Folder.h"

@interface EditEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) BaseEventPreviewElement *eventElement;
@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) Folder *folder;

@end

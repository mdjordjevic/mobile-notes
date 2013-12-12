//
//  StreamPickerViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/12/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"

@class UserHistoryEntry;

@protocol StreamsPickerDelegate;

@interface StreamPickerViewController : BaseViewController

@property (nonatomic, weak) id<StreamsPickerDelegate> delegate;
@property (nonatomic, weak) PYEvent *event;
@property (nonatomic, weak) UserHistoryEntry *entry;

@property (nonatomic, weak) IBOutlet UILabel *streamLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@protocol StreamsPickerDelegate <NSObject>

- (void)changeVisibilityOfStreamPickerTo:(BOOL)visible;
- (void)streamSelected:(PYStream*)stream;

@end

//
//  PhotoNoteViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"
#import "UserHistoryEntry.h"

@interface PhotoNoteViewController : BaseViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UserHistoryEntry *entry;

@end

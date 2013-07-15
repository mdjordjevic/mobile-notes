//
//  AddNumericalValueViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/19/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNumericalKeyboard.h"

@class UserHistoryEntry;

@interface AddNumericalValueViewController : BaseViewController <CustomKeyboardDelegate>

@property (nonatomic, strong) IBOutlet UITextField *valueField;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UserHistoryEntry *entry;

@end

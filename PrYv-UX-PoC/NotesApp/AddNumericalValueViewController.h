//
//  AddNumericalValueViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/19/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNumericalKeyboard.h"
#import "BaseDetailsViewController.h"

@interface AddNumericalValueViewController : BaseViewController <CustomKeyboardDelegate>

@property (nonatomic, strong) IBOutlet UITextField *valueField;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) id<BaseDetailsDelegate> delegate;

@property (nonatomic, strong) NSString *valueClass;
@property (nonatomic, strong) NSString *valueType;
@property (nonatomic, strong) NSString *value;

@end

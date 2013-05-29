//
//  AddNumericalValueViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/19/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNumericalKeyboard.h"

@interface AddNumericalValueViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, CustomKeyboardDelegate>

@property (nonatomic, strong) IBOutlet UITextField *valueField;
@property (nonatomic, strong) IBOutlet UIPickerView *typePicker;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;

@end

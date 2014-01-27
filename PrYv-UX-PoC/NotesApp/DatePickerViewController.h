//
//  DatePickerViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/8/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"

@interface DatePickerViewController : BaseViewController

@property (nonatomic, strong) NSDate *selectedDate;
@property (copy) void (^dateDidChangeBlock)(NSDate *newDate, DatePickerViewController *datePicker);

@end

//
//  CustomNumericalKeyboard.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomNumericalKeyboard;

@protocol CustomKeyboardDelegate <NSObject>

- (UITextField*)textFieldForCustomkeyboard:(CustomNumericalKeyboard*)customKeybord;

@end

@interface CustomNumericalKeyboard : UIView

@property (nonatomic, weak) id<CustomKeyboardDelegate> delegate;

@end

//
//  CustomNumericalKeyboard.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "CustomNumericalKeyboard.h"

@interface CustomNumericalKeyboard ()

@property (nonatomic, weak) UITextField *textField;

- (IBAction)clicked:(UIButton *)sender;

@end

@implementation CustomNumericalKeyboard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self = [[[NSBundle mainBundle] loadNibNamed:@"CustomNumericalKeyboard" owner:self options:nil] objectAtIndex:0];
        self.frame = frame;
    }
    return self;
}

- (void)setDelegate:(id<CustomKeyboardDelegate>)delegate
{
    _delegate = delegate;
}

- (UITextField*)textField
{
    if(!_textField)
    {
        _textField = [_delegate textFieldForCustomkeyboard:self];
    }
    return _textField;
}

- (void)clicked:(UIButton *)sender
{
    NSRange dot = [self.textField.text rangeOfString:@"."];
    
    switch (sender.tag)
    {
        case 10:
            if (dot.location == NSNotFound) {
                self.textField.text = [NSString stringWithFormat:@"%@%@",self.textField.text,@"."];
            }
            break;
        case 11:
            if(self.textField.text.length > 0)
            {
                self.textField.text = [self.textField.text substringToIndex:self.textField.text.length - 1];
            }
            break;
        default:
            if (dot.location == NSNotFound || self.textField.text.length <= dot.location + 2) {
                self.textField.text = [NSString stringWithFormat:@"%@%d",self.textField.text,sender.tag];
            }
            break;
    }
    [_delegate textFieldValueChangedForCustomNumericalKeyboard:self];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end

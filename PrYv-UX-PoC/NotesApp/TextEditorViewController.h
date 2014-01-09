//
//  TextEditorViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"

@protocol TextEditorDelegate;

@interface TextEditorViewController : BaseViewController

@property (nonatomic, strong) NSString *text;
@property (nonatomic, weak) id<TextEditorDelegate> delegate;
@property (copy) void (^textDidChangeCallBack)(NSString* text, TextEditorViewController* textEditor);

@end

@protocol TextEditorDelegate <NSObject>

- (void)textDidChangedTo:(NSString*)text forTextEditor:(TextEditorViewController*)textEditor;

@end
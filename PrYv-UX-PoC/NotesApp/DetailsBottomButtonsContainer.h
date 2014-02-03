//
//  DetailsBottomButtonsContainer.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/30/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsBottomButtonsContainer : UIView

@property (copy) void (^shareButtonTouchHandler)(UIButton *shareButton);
@property (copy) void (^deleteButtonTouchHandler)(UIButton *deleteButton);

@end

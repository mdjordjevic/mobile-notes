//
//  CustomSegmentedControl.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomSegmentedControl;

@protocol CustomSegmentedControlDelegate <NSObject>

- (void)customSegmentedControl:(CustomSegmentedControl*)segmentedControl didSelectIndex:(NSInteger)index;

@end

@interface CustomSegmentedControl : UIView

@property (nonatomic, readonly) NSInteger selectedIndex;
@property (nonatomic, weak) id<CustomSegmentedControlDelegate> delegate;

- (void)selectIndex:(NSInteger)index;

@end

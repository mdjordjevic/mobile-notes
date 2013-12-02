//
//  BaseDetailsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/2/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseDetailsViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *streamsSection;
@property (weak, nonatomic) IBOutlet UIView *tagsSection;

@end

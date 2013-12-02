//
//  ValueDetailsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"

@interface ValueDetailsViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UILabel *eventValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;

@end

//
//  DetailsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/22/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"
#import <PryvApiKit/PryvApiKit.h>

@interface DetailsViewController : BaseViewController

@property (nonatomic, strong) PYEvent *event;

@end

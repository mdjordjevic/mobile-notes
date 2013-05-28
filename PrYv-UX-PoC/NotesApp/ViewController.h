//
//  ViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/24/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMSlideOutNavigationController.h"
#import <PryvApiKit/PryvApiKit.h>
#import <PryvApiKit/PYWebLoginViewController.h>

@interface ViewController : AMSlideOutNavigationController <PYWebLoginDelegate>

- (void)initSignIn;

@end

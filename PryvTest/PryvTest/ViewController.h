//
//  ViewController.h
//  PryvTest
//
//  Created by Neeraj Jaiswal on 03/11/12.
//  Copyright (c) 2012 Softcede. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    IBOutlet UIButton *goBtn;
    IBOutlet UITextView *invokedUrlTextView;
    IBOutlet UITextView *responseTextView;
    IBOutlet UIButton *getChennalsBtn;
    IBOutlet UIButton *getTokensBtn;
}

@property (nonatomic, retain) UIButton *goBtn;
@property (nonatomic, retain) UITextView *invokedUrlTextView;
@property (nonatomic, retain) UITextView *responseTextView;
@property (nonatomic, retain) UIButton *getChennalsBtn;
@property (nonatomic, retain) UIButton *getTokensBtn;
@property (assign) NSString *myIntIVar;



- (IBAction)goButtonTapped:(id)sender;
- (IBAction)getChennalsBtnTapped:(id)sender;
- (IBAction)getTokensBtnTapped:(id)sender;


@end

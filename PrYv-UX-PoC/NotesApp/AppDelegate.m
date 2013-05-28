//
//  AppDelegate.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/24/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "ViewController.h"
#import "NotesAppController.h"
#import "MeasurementController.h"

@interface AppDelegate ()

- (void)initViewControllers;
- (void)setupUI;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NotesAppController sharedInstance];
    [MeasurementController sharedInstance];
    [self initViewControllers];
    [self setupUI];
    
    return YES;
}

- (void)initViewControllers {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
	UIViewController* controller;
	
	self.slideoutController = [[ViewController alloc] init];
	
	[self.slideoutController addSectionWithTitle:@""];
	
	controller = [storyboard instantiateViewControllerWithIdentifier:@"Home1ViewController_ID"];
	[self.slideoutController addViewControllerToLastSection:controller tagged:1 withTitle:@"Collection Add" andIcon:@""];
	
	controller = [storyboard instantiateViewControllerWithIdentifier:@"Home2ViewController_ID"];
	[self.slideoutController addViewControllerToLastSection:controller tagged:2 withTitle:@"Circle Add" andIcon:@""];
    
    controller = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController_ID"];
    [self.slideoutController addViewControllerToLastSection:controller tagged:3 withTitle:@"Settings" andIcon:@""];
    
    controller = [storyboard instantiateViewControllerWithIdentifier:@"AddNumericalValueViewController_ID"];
    [self.slideoutController addViewControllerToLastSection:controller tagged:4 withTitle:@"Add Numerical Value" andIcon:@""];
	
//	[self.slideoutController addActionToLastSection:^{
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Some action"
//                                                        message:@"Some message."
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//		[alert show];
//	}
//											 tagged:3
//										  withTitle:@"Action"
//											andIcon:@""];
	
    [self.window setRootViewController:self.slideoutController];
}

- (void)setupUI {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"menubar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:197.0f/255.0f green:58.0f/255.0f blue:58.0f/255.0f alpha:1]];
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

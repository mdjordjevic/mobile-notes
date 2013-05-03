//
//  Home2ViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "Home2ViewController.h"

@interface Home2ViewController ()

- (void)addCircleMenu;

@end

@implementation Home2ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self addCircleMenu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private API

- (void)addCircleMenu {
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    UIImage *starImage = [UIImage imageNamed:@"icon-star.png"];
    
    NSMutableArray *itemsList = [NSMutableArray arrayWithCapacity:8];
    
    for(int i=0;i<8;i++)
    {
        AwesomeMenuItem *circleMenuItem = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                                highlightedImage:storyMenuItemImagePressed
                                                                    ContentImage:starImage
                                                         highlightedContentImage:nil];
        [itemsList addObject:circleMenuItem];
    }
    
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds menus:itemsList];
    
	// customize menu
	menu.startPoint = isiPhone5 ? CGPointMake(160.0, 460.0) : CGPointMake(160.0, 360.0);
	menu.rotateAngle = -M_PI_2;
	menu.menuWholeAngle = M_PI + M_PI/(itemsList.count - 1);
	menu.timeOffset = 0.05f;
	menu.farRadius = 180.0f;
	menu.endRadius = 100.0f;
	menu.nearRadius = 50.0f;
	
    menu.delegate = self;
    [self.view addSubview:menu];
}

#pragma mark - AwesomeMenuDelegate methods

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx {
    
}

@end

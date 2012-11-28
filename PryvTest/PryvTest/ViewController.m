//
//  ViewController.m
//  PryvTest
//
//  Created by Neeraj Jaiswal on 03/11/12.
//  Copyright (c) 2012 Softcede. All rights reserved.
//

#import "ViewController.h"
//#import "NSString+SBJson.h"
#import "SBJson.h"

@interface ViewController()

@end

@implementation ViewController

@synthesize invokedUrlTextView;
@synthesize responseTextView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)goButtonTapped:(id)sender
{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"https://maninder.rec.la/admin/login"]];
    
    [request setHTTPMethod:@"POST"];
    
    
    NSString *postString = @"username=maninder&password=password&appId=pryv-notes-mobile";
    
    [request setValue:[NSString stringWithFormat:@"%d", [postString length]] forHTTPHeaderField:@"Content-length"];
    
    //NSLog(@"postString = %@",postString);
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
    self.invokedUrlTextView.text=request.URL.absoluteString;
    self.myIntIVar = self.responseTextView.text;
    //NSLog(@"test %@",self.myIntIVar);
}




- (IBAction)getChennalsBtnTapped:(id)sender
{
    
    
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:
     [NSURL URLWithString:@"https://maninder.rec.la/admin/channels"]];
    
    
    
    [request setHTTPMethod:@"GET"];
    
    
    // Parse the string into JSON
    SBJsonParser *jsonParser = [SBJsonParser new];
    //NSLog(@"response = %@",self.responseTextView.text);
    NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:self.responseTextView.text error:nil];
    //NSLog(@"%@",jsonData);
    NSString *sessionId = (NSString*)[jsonData objectForKey:@"sessionID"];
    //NSLog(@"%d",success);
    NSLog(@"sessionId = %@",sessionId);
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"maninder", @"userName", @"password", @"password",@"pryv-notes-mobile", @"appId",sessionId, @"Authorization", nil];
    [request setAllHTTPHeaderFields:dict];
    
    
    [[NSURLConnection alloc]
     initWithRequest:request delegate:self];
    
    
    self.invokedUrlTextView.text=request.URL.absoluteString;
    
    
}


- (IBAction)getTokensBtnTapped:(id)sender
{
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:
     [NSURL URLWithString:@"https://maninder.rec.la/admin/get-app-token"]];
    
    
    [request setHTTPMethod:@"POST"];
    
    
    // Parse the string into JSON
    SBJsonParser *jsonParser = [SBJsonParser new];
    
    NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:self.responseTextView.text error:nil];
    
    NSString *sessionId = (NSString*)[jsonData objectForKey:@"sessionID"];
    
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          sessionId, @"Authorization", nil];
    
    
    [request setAllHTTPHeaderFields:dict];
    
    [[NSURLConnection alloc]
     initWithRequest:request delegate:self];
    
    
    self.invokedUrlTextView.text=request.URL.absoluteString;
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //    [self.data setLength:0];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    //    [self.data appendData:d];
    
    
    
    self.responseTextView.text = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    
    // Do anything you want with it
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
    //                                 message:[error localizedDescription]
    //                                delegate:nil
    //                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
    //                       otherButtonTitles:nil] autorelease] show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    
    //    NSString *responseText = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    
    // Do anything you want with it
    //    [responseText release];
}


@end

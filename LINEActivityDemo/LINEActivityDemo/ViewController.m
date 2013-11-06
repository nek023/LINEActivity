//
//  ViewController.m
//  LINEActivityDemo
//
//  Created by Tanaka Katsuma on 2013/11/06.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import "ViewController.h"

// LINEActivity
#import "LINEActivity.h"

@interface ViewController ()

@property (nonatomic, assign, getter = isLoading) BOOL loading;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Load URL
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/questbeat"]];
    [self.webView loadRequest:request];
}


#pragma mark - Actions

- (IBAction)back:(id)sender
{
    [self.webView goBack];
}

- (IBAction)forward:(id)sender
{
    [self.webView goForward];
}

- (IBAction)refresh:(id)sender
{
    [self.webView reload];
}

- (void)stop:(id)sender
{
    [self.webView stopLoading];
}

- (IBAction)action:(id)sender
{
    // Show activity view controller
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSURL *URL = [NSURL URLWithString:[self.webView stringByEvaluatingJavaScriptFromString:@"document.URL"]];
    
    LINEActivity *lineActivity = [[LINEActivity alloc] init];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[title, URL]
                                                                                         applicationActivities:@[lineActivity]];
    [self presentViewController:activityViewController animated:YES completion:NULL];
}


#pragma mark - Updating the View

- (void)configureView
{
    // Replace button
    NSMutableArray *items = [self.toolbar.items mutableCopy];
    
    if ([self isLoading]) {
        UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                    target:self
                                                                                    action:@selector(stop:)];
        
        [items replaceObjectAtIndex:5 withObject:stopButton];
    } else {
        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                       target:self
                                                                                       action:@selector(refresh:)];
        
        [items replaceObjectAtIndex:5 withObject:refreshButton];
    }
    
    [self.toolbar setItems:[items copy] animated:NO];
    
    // Update bar buttons
    [self.backButton setEnabled:self.webView.canGoBack];
    [self.forwardButton setEnabled:self.webView.canGoForward];
    
    // Get the title
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.loading = YES;
    
    // Update view
    [self configureView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.loading = NO;
    
    // Update view
    [self configureView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // Update view
    [self configureView];
}

@end

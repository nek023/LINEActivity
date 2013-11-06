//
//  LINEActivity.m
//  LINEActivity
//
//  Created by Tanaka Katsuma on 2013/11/06.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import "LINEActivity.h"

@interface LINEActivity ()

@property (nonatomic, copy) NSArray *activityItems;

@end

@implementation LINEActivity

- (NSString *)activityType
{
    return @"jp.naver.LINEActivity";
}

- (UIImage *)activityImage
{
    // Check if it runs on iOS 7 or not
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return [UIImage imageNamed:@"LINEActivityImage-iOS7"];
    } else {
        return [UIImage imageNamed:@"LINEActivityImage"];
    }
}

- (NSString *)activityTitle
{
    return @"LINE";
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSString class]] || [activityItem isKindOfClass:[NSURL class]] || [activityItem isKindOfClass:[UIImage class]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    self.activityItems = activityItems;
}

- (void)performActivity
{
    // Check whether LINE is installed or not
    if (![[self class] isLINEInstalled]) {
        // Show alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"alert_title", @"LINEActivity", nil)
                                                            message:NSLocalizedStringFromTable(@"alert_message", @"LINEActivity", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedStringFromTable(@"alert_button_cancel", @"LINEActivity", nil)
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"alert_button_open", @"LINEActivity", nil), nil];
        [alertView show];
        
        return;
    }
    
    // Perform activity items
    NSMutableArray *stringItems = [NSMutableArray array];
    NSMutableArray *URLItems = [NSMutableArray array];
    
    for (id activityItem in self.activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            // Open LINE with image
            [self openLINEWithImage:activityItem];
        }
        else if ([activityItem isKindOfClass:[NSString class]]) {
            [stringItems addObject:activityItem];
        }
        else if ([activityItem isKindOfClass:[NSURL class]]) {
            [URLItems addObject:activityItem];
        }
    }
    
    if (stringItems.count > 0 || URLItems.count > 0) {
        NSMutableArray *items = [NSMutableArray array];
        [items addObjectsFromArray:stringItems];
        [items addObjectsFromArray:URLItems];
        
        // Open LINE with text
        NSString *string = [items componentsJoinedByString:@" "];
        [self openLINEWithString:string];
    }
    
    // Notifies the system that the activity has finished
    [self activityDidFinish:YES];
}


#pragma mark - Helper

- (NSString *)encodeURLString:(NSString *)string usingEncoding:(NSStringEncoding)encoding
{
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

+ (BOOL)isLINEInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]];
}

- (void)openLINEOnAppStore
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/line/id443904275?mt=8"]];
}

- (void)openLINEWithString:(NSString *)string
{
    NSString *URLString = [NSString stringWithFormat:@"line://msg/text/%@", [self encodeURLString:string usingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
}

- (void)openLINEWithImage:(UIImage *)image
{
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithUniqueName];
    NSData *imageData = UIImagePNGRepresentation(image);
    [pasteboard setData:imageData forPasteboardType:@"public.png"];
    
    NSString *URLString = [NSString stringWithFormat:@"line://msg/image/%@", [self encodeURLString:pasteboard.name usingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Open LINE on AppStore
        [self openLINEOnAppStore];
    }
    
    // Notifies the system that the activity has finished
    [self activityDidFinish:YES];
}

@end

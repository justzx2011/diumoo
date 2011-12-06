//
//  diumooAppDelegate.m
//  diumoo
//
//  Created by Shanzi on 11-12-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "diumooAppDelegate.h"

@implementation diumooAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    c=[[doubanFMController alloc] init];
    [c authWithUsername:@"airobot1@163.com" andPassword:@"akirasphere"];
    [c requestPlaylistWithType:NEW andSid:@""];
}

@end

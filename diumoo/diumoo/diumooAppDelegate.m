//
//  diumooAppDelegate.m
//  diumoo
//
//  Created by Shanzi on 11-12-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "diumooAppDelegate.h"

@implementation diumooAppDelegate

//@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    g=[[growlNotifier alloc] init];
    s=[[doubanFMSource alloc] init];
    p=[[musicPlayer alloc] init];
    c=[[musicController alloc] init];
    [c setSource:s];
    [c setPlayer:p];
    NSLog(@"wait for 30s");
    [NSThread sleepForTimeInterval:30];
    NSLog(@"will pause");
    [c pause];
    NSLog(@"paused");
    NSLog(@"wait for 10s");
    [NSThread sleepForTimeInterval:10];
    NSLog(@"will play");
    [c play];
    NSLog(@"played");
    NSLog(@"wait for 30s");
    [NSThread sleepForTimeInterval:30];
    NSLog(@"will skip");
    [c skip];
    NSLog(@"skiped");
    NSLog(@"wait for 30s");
    [NSThread sleepForTimeInterval:30];
    NSLog(@"will change channel");
    [c changeChannelTo:4];
    NSLog(@"channel changed");
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
    [c pause];
}

@end
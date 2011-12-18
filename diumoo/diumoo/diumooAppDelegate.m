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
    g=[[notifier alloc] init];
    s=[[doubanFMSource alloc] init];
    p=[[musicPlayer alloc] init];
    c=[[controlCenter alloc] init];
    m=[[menu alloc]init];
    [m setController:c];
    [self performSelectorInBackground:@selector(backinit) withObject:nil];
}

-(void)backinit
{
    [c setSource:s];
    [c setPlayer:p];
    [c startToPlay];
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
    [c pause];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo" object:@"com.apple.iTunes.player" userInfo:nil];
}


@end
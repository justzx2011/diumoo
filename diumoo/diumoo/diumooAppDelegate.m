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
    [c setSource:s];
    [c setPlayer:p];
    [c performSelectorInBackground:@selector(startToPlay) withObject:nil];
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
    [c pause];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo" object:@"com.apple.iTunes.player" userInfo:nil];
}

-(IBAction)showPreference:(id)sender
{
    if([NSThread isMainThread])
    {
        [self performSelectorInBackground:@selector(showPreference:) withObject:sender];
        return;
    }
    if([sender tag]==3) [preference showPreferenceWithView:INFO_PREFERENCE_ID];
    else [preference showPreferenceWithView:GENERAL_PREFERENCE_ID];
}


@end
//
//  diumooAppDelegate.m
//  diumoo
//
//  Created by Shanzi on 11-12-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "diumooAppDelegate.h"
#import "preference.h"
#import "controlCenter.h"

@implementation diumooAppDelegate

//@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    g=[[notifier alloc] init];
    s=[[doubanFMSource alloc] init];
    p=[[musicPlayer alloc] init];
    m=[[menu alloc]init];
    
    [preference sharedPreference];
     
    [[controlCenter sharedCenter] setPlayer:p];
    [[controlCenter sharedCenter] setSource:s];
    [controlCenter tryAuth:[preference authPrefsData]];
    [[controlCenter sharedCenter] performSelectorInBackground:@selector(startToPlay) withObject:nil ];
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
    [[controlCenter sharedCenter] pause];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo" object:@"com.apple.iTunes.player" userInfo:nil];
}

-(IBAction)showPreference:(id)sender
{
    if([sender tag]==3) [preference showPreferenceWithView:INFO_PREFERENCE_ID];
    else [preference showPreferenceWithView:GENERAL_PREFERENCE_ID];
}

-(void) dealloc
{
    [g release];
    [s release];
    [p release];
    [m release];
    [super dealloc];
}



@end
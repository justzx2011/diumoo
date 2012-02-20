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

-(void) dealloc
{
    [controller release];
    [growlnotify release];
    [source release];
    [player release];
    [dmmenu release];
    [keyTap release];
    [super dealloc];
}

+(void) initialize
{
    if([self class] != [diumooAppDelegate class]) 
        return;
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,nil]];
    
}

-(void) firstLaunch
{
    controller=[NSUserDefaultsController sharedUserDefaultsController];
    if([[controller values] valueForKey:@"IsFirstLaunch"]==nil)
    {
        [[controller values] setValue:[NSNumber numberWithInteger:NSOnState] forKey:@"ShowDockIcon"];
        [[controller values] setValue:[NSNumber numberWithInteger:NSOnState] forKey:@"EnableGrowl"];
        [[controller values] setValue:[NSNumber numberWithInteger:NSOnState] forKey:@"PlayPauseFastHotKey"];
        [[controller values] setValue:[NSNumber numberWithInteger:NSOnState] forKey:@"RateHotKey"];
        [[controller values] setValue:[NSNumber numberWithInteger:NSOnState] forKey:@"TwitterDoubanInfo"];
        [[controller values] setValue:[NSNumber numberWithInteger:NSOnState] forKey:@"ShowAlbumOnDock"];
        [[controller values] setValue:[NSNumber numberWithInt:2] forKey:@"DesktopWaveLevel"];
        [[controller values] setValue:[NSNumber numberWithInt:1] forKey:@"GoogleSearchType"];
        [[controller values] setValue:[NSNumber numberWithBool:NO] forKey:@"IsFirstLaunch"];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:1] forKey:@"PlayedChannel"];        
    }
   
}

- (void)applicationDidFinishLaunching:(NSNotification *)Notification
{
    [self firstLaunch];
    growlnotify=[[notifier alloc] init];
    source=[[doubanFMSource alloc] init];
    player=[[diumooPlayer alloc] init];
    dmmenu=[[menu alloc]init];
    
     
    [[controlCenter sharedCenter] setPlayer:player];
    [[controlCenter sharedCenter] setSource:source];
    
    
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
    
    if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"ShowDockIcon"] integerValue]==NSOnState)
    {
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    }
    
    [dmmenu performSelectorInBackground:@selector(fireToPlayTheDefaultChannel) withObject:nil];
    
    
    [[SUUpdater sharedUpdater] setDelegate:self];
    [[SUUpdater sharedUpdater] checkForUpdatesInBackground];
}

-(void) updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update
{
    [NSApp activateIgnoringOtherApps:YES];
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
    [[NSApp dockTile] setBadgeLabel:@""];
    [NSApp setApplicationIconImage:nil];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo" object:@"com.apple.iTunes.player" userInfo:[NSDictionary dictionaryWithObject:@"Paused" forKey:@"Player State"]];
    [player lazyPause];
}

-(IBAction)showPreference:(id)sender
{
    if([sender tag]==3) 
        [preference showPreferenceWithView:INFO_PREFERENCE_ID];
    else [preference showPreferenceWithView:GENERAL_PREFERENCE_ID];
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event{
    
    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([event data1] & 0x0000FFFF);
    int keyState = (((keyFlags & 0xFF00) >> 8)) ==0xA;
    if(keyState==0)
        switch (keyCode) {
            case NX_KEYTYPE_PLAY:
                if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"PlayPauseFastHotKey"] integerValue]==NSOnState)
                    [[controlCenter sharedCenter] play_pause];
                break;
            case NX_KEYTYPE_FAST:
                if(([event modifierFlags] & NSShiftKeyMask) && [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"ByeHotKey"]) [[controlCenter sharedCenter] bye];
                else if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"PlayPauseFastHotKey"] integerValue]==NSOnState)
                    [[controlCenter sharedCenter] skip];
                break;
            case NX_KEYTYPE_REWIND:
                
                if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"RateHotKey"] integerValue]==NSOnState)
                    if([dmmenu lightHeart])[[controlCenter sharedCenter] rate];
                break;
        }

}

@end

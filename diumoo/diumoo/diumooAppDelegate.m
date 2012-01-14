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

+(void) initialize
{
    if([self class] != [diumooAppDelegate class]) 
        return;
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,nil]];
}

-(void) firstLaunch
{
    NSUserDefaultsController* controller=[NSUserDefaultsController sharedUserDefaultsController];
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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self firstLaunch];
    growlnotify=[[notifier alloc] init];
    source=[[doubanFMSource alloc] init];
    player=[[musicPlayer alloc] init];
    dmmenu=[[menu alloc]init];
    
    //NSLog([NSString stringWithFormat:@"GrowlNotify retain count: %i",[growlnotify retainCount]]);
    //NSLog([NSString stringWithFormat:@"Source retain count: %i",[source retainCount]]);
    //NSLog([NSString stringWithFormat:@"Player retain count: %i",[musicPlayer retainCount]]);
    //NSLog([NSString stringWithFormat:@"dmmenu retain count: %i",[dmmenu retainCount]]);
    
    //[preference sharedPreference];
     
    [[controlCenter sharedCenter] setPlayer:player];
    [[controlCenter sharedCenter] setSource:source];
    
    
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
    
    if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"ShowDockIcon"] integerValue]==NSOnState){
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    }
    
    [dmmenu performSelectorInBackground:@selector(fireToPlayTheDefaultChannel) withObject:nil];
    
    
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
    [player lazyPause];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.iTunes.playerInfo" object:@"com.apple.iTunes.player" userInfo:[NSDictionary dictionaryWithObject:@"Paused" forKey:@"Player State"]];
}

-(IBAction)showPreference:(id)sender
{
    if([sender tag]==3) [preference showPreferenceWithView:INFO_PREFERENCE_ID];
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
                if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"PlayPauseFastHotKey"] integerValue]==NSOnState)
                    [[controlCenter sharedCenter] skip];
                break;
            case NX_KEYTYPE_REWIND:
                if([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"RateHotKey"] integerValue]==NSOnState)
                    if([dmmenu lightHeart])[[controlCenter sharedCenter] rate];
                break;
        }

}


-(void) dealloc
{
    
    [growlnotify release];
    [source release];
    [player release];
    [dmmenu release];
    [keyTap release];
    [super dealloc];
}



@end

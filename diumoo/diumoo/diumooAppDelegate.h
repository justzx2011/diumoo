//
//  diumooAppDelegate.h
//  diumoo
//
//  Created by Shanzi on 11-12-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "doubanFMSource.h"
#import "diumooPlayer.h"
#import "notifier.h"
#import "menuController.h"
#import "SPMediaKeyTap.h"

@interface diumooAppDelegate : NSObject <NSApplicationDelegate> {

    NSUserDefaultsController* controller;
    diumooPlayer* player;
    doubanFMSource* source;
    notifier* growlnotify;
    menuController* dmmenu;
    SPMediaKeyTap *keyTap;

}

-(void)firstLaunch;
-(void)applicationWillTerminate:(NSNotification *)notification;
-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;

-(IBAction)showPreference:(id)sender;

-(IBAction)dockMenuItemActions:(id)sender;

@end

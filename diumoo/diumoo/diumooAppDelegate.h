//
//  diumooAppDelegate.h
//  diumoo
//
//  Created by Shanzi on 11-12-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "doubanFMSource.h"
#import "musicPlayer.h"
#import "notifier.h"
#import "menu.h"
#import "SPMediaKeyTap.h"

@interface diumooAppDelegate : NSObject <NSApplicationDelegate> {
    //NSWindow *window;
    musicPlayer* p;
    doubanFMSource* s;
    notifier* g;
    menu* m;
    SPMediaKeyTap *keyTap;

}

-(void) firstLaunch;
-(void) applicationWillTerminate:(NSNotification *)notification;
-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;

-(IBAction)showPreference:(id)sender;

@end

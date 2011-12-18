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
#import "controlCenter.h"
#import "preference.h"

@interface diumooAppDelegate : NSObject <NSApplicationDelegate> {
    //NSWindow *window;
    musicPlayer* p;
    doubanFMSource* s;
    controlCenter* c;
    notifier* g;
    menu* m;
}

-(void) backinit;
-(void) applicationWillTerminate:(NSNotification *)notification;

-(IBAction)showPreference:(id)sender;

@end

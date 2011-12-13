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
#import "musicController.h"
#import "growlNotifier.h"
#import "menu.h"
#import "musicVisualizer.h"

@interface diumooAppDelegate : NSObject <NSApplicationDelegate> {
    //NSWindow *window;
    musicPlayer* p;
    doubanFMSource* s;
    musicController* c;
    growlNotifier* g;
    menu* m;
    musicVisualizer* v;
    
}

-(void) backinit;
-(void) applicationWillTerminate:(NSNotification *)notification;

@end

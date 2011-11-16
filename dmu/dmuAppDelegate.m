//
//  dmuAppDelegate.m
//  dmu
//
//  Created by Shanzi on 11-10-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "dmuAppDelegate.h"


@implementation dmuAppDelegate
@synthesize mainMenu,window;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    statusItem=[[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    [statusItem setImage:[NSImage imageNamed:@"icon.png"]];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:mainMenu];
    
    [window makeKeyAndOrderFront:window];

}



-(void)applicationDidBecomeActive:(NSNotification *)notification
{
    [window show];
}

-(void)applicationDidResignActive:(NSNotification *)notification
{
    [window hide];
}

-(IBAction)showOrHideQuickbox:(id)sender
{
    [window showOrHide];
}

-(IBAction)pinQuickbox:(NSMenuItem*)sender
{
    if ([sender state]==NSOnState) {
        [window pin:NO];
        [sender setState:NSOffState];
    }
    else{
        [window pin:YES];
        [sender setState:NSOnState];
    }
}

-(IBAction)exit:(id)sender
{
    [window exit:NO];
}


@end

//
//  dmuAppDelegate.m
//  dmu
//
//  Created by Shanzi on 11-10-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "dmuAppDelegate.h"


@implementation dmuAppDelegate
@synthesize window;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [window setStyleMask:NSBorderlessWindowMask];
    [window setBackgroundColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1] ];
    [window setTitle:@"test"];
    
    [window setMovableByWindowBackground:NO];
    [window setFrame:NSMakeRect(0, 0, 600, 300) display:YES];
    
    [window setShowsResizeIndicator:NO];
    [window makeKeyAndOrderFront:window];
    [window makeMainWindow];
    
    
}



@end

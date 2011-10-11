//
//  dmuAppDelegate.m
//  dmu
//
//  Created by Shanzi on 11-10-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "dmuAppDelegate.h"


@implementation dmuAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    statusMenu=[[[NSMenu alloc] init] retain];
    viewContainer= [[[NSMenuItem alloc]init] retain];
    fmcontroller=[[[FmController alloc] init] retain];
    [viewContainer setView: [fmcontroller webView]];
    [statusMenu addItem:viewContainer];
    //[statusMenu addItemWithTitle:@"TEST" action:nil keyEquivalent:@""];
    statusItem= [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength]retain];
    [statusItem setImage: [[NSImage alloc] initByReferencingFile:
                           [[NSBundle mainBundle] pathForResource:@"statusitem" ofType:@"png" inDirectory:@"douban"]]]; 
    [statusItem setMenu:statusMenu];

    [statusItem setHighlightMode:YES];
    
    
    
}

@end

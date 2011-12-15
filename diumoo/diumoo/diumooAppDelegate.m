//
//  diumooAppDelegate.m
//  diumoo
//
//  Created by Shanzi on 11-12-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "diumooAppDelegate.h"

@implementation diumooAppDelegate

//@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    g=[[[growlNotifier alloc] init] retain];
    s=[[[doubanFMSource alloc] init] retain];
    p=[[[musicPlayer alloc] init] retain];
    c=[[[controlCenter alloc] init] retain];
    m=[[[menu alloc]init] retain];
    [m setController:c];
    [self performSelectorInBackground:@selector(backinit) withObject:nil];
}

-(void)backinit
{
    [c setSource:s];
    [c setPlayer:p];
}

-(void) applicationWillTerminate:(NSNotification *)notification
{
    [c pause];
}

@end
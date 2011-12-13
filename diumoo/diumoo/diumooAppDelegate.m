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
    c=[[[musicController alloc] init] retain];
    m=[[[menu alloc]init] retain];
    v= [[musicVisualizer alloc] init];
    [s authWithUsername:@"airobot1@163.com" andPassword:@"akirasphere"];
    [m setController:c];
    [self performSelectorInBackground:@selector(backinit) withObject:nil];
    [v showWindow:self];

    
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
//
//  MainWindow.m
//  dmu
//
//  Created by Shanzi on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MainWindow.h"

@implementation MainWindow


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        

        NSRect r=[[NSScreen mainScreen] frame];
        NSRect f=NSMakeRect(r.size.width/2-310,r.size.height-272, 620, 250);
        webview=[[WebView alloc] initWithFrame:f];
        [[webview mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"douban"]]]];
        [webview displayIfNeeded];

        

        [self setFrame:f display:YES];
        [self setLevel:NSDockWindowLevel];
        [self setBackingType:NSBackingStoreBuffered];
        [self setStyleMask:NSBorderlessWindowMask];
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:1 alpha:1]];
        [self setMovable:NO];
        [self setContentView:webview];
        [self setContentSize:f.size];
        [self setAlphaValue:0.9];
        [self displayIfNeeded];
    }
    
    return self;
}
-(BOOL) acceptsFirstResponder;
{
    return YES;
}

@end

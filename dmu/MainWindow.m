//
//  MainWindow.m
//  dmu
//
//  Created by Shanzi on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MainWindow.h"

@implementation MainWindow
@synthesize webview;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        

        NSRect r=[[NSScreen mainScreen] frame];
        NSRect f=NSMakeRect(r.size.width/2-310,r.size.height-272, 620, 250);
        

        

        [self setFrame:f display:YES];
        [self setLevel:NSDockWindowLevel];
        [self setBackingType:NSBackingStoreBuffered];
        [self setStyleMask:NSBorderlessWindowMask];
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:1 alpha:1]];
        [self setMovable:NO];
        [self setContentSize:f.size];
        [self setAlphaValue:0.9];
        
        webview=[[WebView alloc] initWithFrame:[[self contentView]bounds]];
        [[webview mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"douban"]]]];
        [webview displayIfNeeded];
        
        [[self contentView] addSubview:webview];
        [self makeFirstResponder:webview];
        
        [self displayIfNeeded];
        
    }
    
    return self;
}


@end

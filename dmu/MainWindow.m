//
//  MainWindow.m
//  dmu
//
//  Created by Shanzi on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MainWindow.h"

@implementation MainWindow
@synthesize webview,quickMsgBox;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        //初始化所有的frame
        NSRect r=[[NSScreen mainScreen] frame];
        _show=NSMakeRect(r.size.width/2-300,r.size.height-142, 600, 120);
        _hide=NSMakeRect(r.size.width/2-300,r.size.height, 600, 120);
        
        
        
        
        //初始化主窗口
        [self setFrame:_hide display:YES];
        //[self setLevel:NSModalPanelWindowLevel];
        [self setBackingType:NSBackingStoreBuffered];
        [self setStyleMask:NSBorderlessWindowMask];
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:1 alpha:1]];
        
        //初始化关闭按钮
        _exit=[[NSButton alloc] initWithFrame:NSMakeRect(580,100, 10, 10)];
        [_exit setImage:[NSImage imageNamed:@"exit.png"]];
        [_exit setBordered:NO];
        
        [_exit setAction:@selector(die)];
        [_exit displayIfNeeded];
        
        
        //初始化webview
        webview=[[WebView alloc] initWithFrame:[[self contentView]bounds]];
        [[webview mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"douban"]]]];
        [webview displayIfNeeded];
        
        
        [[self contentView] addSubview:webview];
        [[self contentView] addSubview:_exit];
        [self displayIfNeeded];
        
    }
    
    return self;
}




-(BOOL)canBecomeKeyWindow
{
    return YES;
}
-(void) hide
{
    [self setFrame:_hide display:YES animate:YES];

}
-(void) show
{  
    [self setFrame:_show display:YES animate:YES];
}

-(void) wake
{
    [NSApp activateIgnoringOtherApps:YES];
}
-(void) die
{
    [NSApp terminate:nil];
}

@end

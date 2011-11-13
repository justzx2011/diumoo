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
        
        //初始化所有的frame
        NSRect r=[[NSScreen mainScreen] frame];
        _show=NSMakeRect(r.size.width/2-300,r.size.height,600,122);
        _original_hide=NSMakeRect(r.size.width/2-300,r.size.height,600,122);
        _hide=NSMakeRect(r.size.width/2-300,r.size.height-52,600,122);
        
        
        //初始化主窗口
        [self setFrame:_hide display:YES];
        [self setLevel:NSModalPanelWindowLevel];
        [self setBackingType:NSBackingStoreBuffered];
        [self setStyleMask:NSBorderlessWindowMask];
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:1 alpha:1]];
        
        //初始化menubar icon
        _menubar_icon=[[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
        
        //hack icon的位置
        
        NSView *tmpView = [[NSView alloc] initWithFrame:NSMakeRect(0.0,0.0, [_menubar_icon length], [[_menubar_icon statusBar] thickness])];
        [_menubar_icon setView:tmpView];
        [[[_menubar_icon view] window] frame];
        NSLog(@"%@",icon_frame);
        [_menubar_icon setView:nil];
        [tmpView release];
        [_menubar_icon setImage:[NSImage imageNamed:@"icon.png"]];
        

        
        //初始化webview
        webview=[[WebView alloc] initWithFrame:[[self contentView]bounds]];
        [webview displayIfNeeded];
        [webview setFrameLoadDelegate:self];
        
        //开始加载页面
        //[self loadRequest:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"douban"]]];
        
        [[self contentView] addSubview:webview];
        [self display];
        [self hide];
        
    }
    
    return self;
}
-(void) dealloc
{
    [webview release];
    [super dealloc];
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
-(void) exit
{
    _show=_original_hide;
    [self show];
    [NSApp terminate:nil];
}
-(void) pin:(BOOL)pined
{
    if(pined){ _hide.origin.y=_show.origin.y;_pined=YES;}
    else{
        _hide.origin.y=_original_hide.origin.y;
        _pined=NO;
    }
}

-(void) preferences
{
    [self hide];
    if(_preferences) [_preferences makeKeyAndOrderFront:_preferences];
}




//loader部分的函数实现

-(void) ready
{
    _hide.origin.y=_original_hide.origin.y;
    [self wake];
}

-(NSString*) authKey
{
    return [NSString stringWithFormat:@"({'email':'%s','pass':'%s'})","airobot1@163.com","akirasphere"];
    //return nil;
}

-(NSNumber*) channel
{
    return [[webview windowScriptObject] evaluateWebScript:@"channel();"];
}
-(void) channel:(NSNumber *)n
{
    [[webview windowScriptObject] evaluateWebScript:[NSString stringWithFormat:@"channel(%d);",[n intValue]]];
}

-(void) error:(NSString *)detail
{
    NSLog(@"%@",detail);
}
-(void) signal:(NSString *)s
{
    NSLog(@"%@",s);
}
-(NSDictionary*) nowplaying
{
    return [NSDictionary dictionaryWithDictionary:_nowplaying];
}

-(void) loadRequest:(NSURL*)url
{
    [[webview mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
}

// Webview Delegate

-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    _show.origin.y=_original_hide.origin.y-122;
    [self show];
    [[sender windowScriptObject] evaluateWebScript:@"startInitialize()"];
}
-(void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
    [windowObject setValue:self forKey:@"domi"];
}

+(BOOL) isSelectorExcludedFromWebScript:(SEL)selector
{
    if (selector==@selector(authKey)) return NO;
    if (selector==@selector(channel)) return NO;
    if (selector==@selector(channel:)) return NO;
    if (selector==@selector(error:)) return NO;
    if (selector==@selector(signal:)) return NO;
    if (selector==@selector(ready)) return NO;
    if (selector==@selector(exit)) return NO;
    if (selector==@selector(pin:)) return NO;
    if (selector==@selector(preferences)) return NO;
    return YES;
}



@end

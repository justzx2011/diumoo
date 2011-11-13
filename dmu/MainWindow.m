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
        _show=NSMakeRect(r.size.width/2-300,r.size.height-122,600,122);
        _hide=NSMakeRect(r.size.width/2-300,r.size.height,600,122);
        
        
        
        
        //初始化主窗口
        [self setFrame:_hide display:YES];
        [self setLevel:NSModalPanelWindowLevel];
        [self setBackingType:NSBackingStoreBuffered];
        [self setStyleMask:NSBorderlessWindowMask];
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:1 alpha:1]];
        
        
        
        //初始化webview
        webview=[[WebView alloc] initWithFrame:[[self contentView]bounds]];
        [webview displayIfNeeded];
        [webview setFrameLoadDelegate:self];
        
        
        //开始加载页面
        [self loadRequest:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"douban"]]];
        
        [[self contentView] addSubview:webview];
        [self display];
        [self hide];
        
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

//loader部分的函数实现

-(NSString*) authKey
{
    return [NSString stringWithFormat:@"({'email':'%s','pass':'%s'})","airobot1@163.com","akirasphere"];
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
    return YES;
}



@end

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
        _pined=NO;
        _ready=NO;
        _loading=NO;
        _quick_showing=NO;
        
        //初始化所有的frame
        NSRect r=[[NSScreen mainScreen] frame];
        float h=[[NSStatusBar systemStatusBar] thickness];
        _show=NSMakeRect(r.size.width/2-300,r.size.height-100.0-h,600.0,100.0+h);
        _hide=NSMakeRect(r.size.width/2-300,r.size.height,600.0,100.0+h);
        _tiny=NSMakeRect(r.size.width/2-300,r.size.height-40.0-h,600.0,100.0+h);
        _tiny_out_rect=NSMakeRect(r.size.width/2-300,r.size.height-h-40.0, 600, h+50.0);
        active_border=r.size.height-1.0;
        
        
        //初始化主窗口
        [self setFrame:_hide display:YES];
        [self setLevel:NSModalPanelWindowLevel];
        [self setBackingType:NSBackingStoreBuffered];
        [self setStyleMask:NSBorderlessWindowMask];
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:1 alpha:1]];
        [self setCollectionBehavior:NSWindowCollectionBehaviorTransient];
        

        
        //初始化webview
        webview=[[WebView alloc] initWithFrame:[[self contentView]bounds]];
        [webview displayIfNeeded];
        [webview setFrameLoadDelegate:self];
        
        //开始加载页面
        [self loadRequest:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"douban"]]];
        
        [[self contentView] addSubview:webview];
        [self display];
        [self setFrame:_hide display:YES];
        
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
    if(_pined) [self tiny];
    else if(_loading && !_ready) [self setFrame:_tiny display:YES];
    else {
        [self setFrame:_hide display:YES animate:YES];
        _quick_showing=NO;
    }

}
-(void) show
{   
    if(_ready)
    {
        if(_quick_showing){
            [self setFrame:_show display:YES];
            _quick_showing=NO;
        }
        else [self setFrame:_show display:YES animate:YES];
        [[webview windowScriptObject] evaluateWebScript:@"tiny(false);"];
    }
}

-(void) showOrHide
{
    if([self frame].origin.y!=_show.origin.y) [self show];
    else [self hide];
}


-(void) exit:(BOOL)now
{
    if(now) {
        [self setFrame:_hide display:YES animate:YES];
        [NSApp terminate:nil];
        return;
    }
    [[webview windowScriptObject] evaluateWebScript:@"exit();"];

    
}
-(void) pin:(BOOL)pined
{
    _pined=pined;
    if(pined) [self tiny];
}





//loader部分的函数实现

-(void) ready
{
    _ready=YES;
    [self show];
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent* e){
        if(_pined);
        else if([NSEvent mouseLocation].y>active_border){
            [self tiny];
        }
        else if(_quick_showing && !NSPointInRect([NSEvent mouseLocation], _tiny_out_rect)){
            [self hide];
        }
        
    }];
}

-(void) tiny
{
    _quick_showing=YES;
    [self setFrame:_tiny display:YES];
    [[webview windowScriptObject] evaluateWebScript:@"tiny(true);"];
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
    _ready=NO;
    [[webview mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
}

// Webview Delegate


-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    [self setFrame:_show display:YES animate:YES];
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
    if (selector==@selector(error:)) return NO;
    if (selector==@selector(signal:)) return NO;
    if (selector==@selector(ready)) return NO;
    if (selector==@selector(exit:)) return NO;
    if (selector==@selector(preferences)) return NO;
    return YES;
}



@end

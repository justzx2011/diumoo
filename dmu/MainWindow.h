//
//  MainWindow.h
//  dmu
//
//  Created by Shanzi on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>


@interface MainWindow : NSWindow 
{
@protected
    WebView* webview;
    NSRect icon_frame;
    NSMutableDictionary* _nowplaying;
    NSRect _show;
    NSRect _hide;
    NSRect _tiny;
    NSRect _tiny_out_rect;
    BOOL _pined;
    BOOL _ready;
    BOOL _loading;
    BOOL _quick_showing;
    float active_border;
}
@property(nonatomic,retain) WebView* webview;


-(BOOL) canBecomeKeyWindow;

-(void) hide;
-(void) show;
-(void) showOrHide;

-(void) exit:(BOOL)now;
-(void) pin:(BOOL) pined; //将窗口锁定
-(void) reload;



// loader 部分的函数
-(void) ready;
-(void) tiny;

-(void) error:(NSString*)detail;
-(void) signal:(NSString*)s;

-(NSString*) authKey;
-(BOOL) channel:(NSInteger)n;
-(BOOL) dj_channel:(NSInteger) n withPid: (NSInteger) pid;
-(NSDictionary *) nowplaying;

-(void) loadRequest:(NSURL*) url;

-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame;
-(void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame;

+(BOOL) isSelectorExcludedFromWebScript:(SEL)selector;

@end

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
    IBOutlet NSWindow* _preferences;
    NSStatusItem* _menubar_icon;
    NSRect icon_frame;
    NSMutableDictionary* _nowplaying;
    NSRect _show;
    NSRect _original_hide;
    NSRect _hide;
    BOOL _pined;
}
@property(nonatomic,retain) WebView* webview;

-(BOOL) canBecomeKeyWindow;


-(void) hide;
-(void) show;
-(void) wake;
-(void) exit;
-(void) pin:(BOOL) pined; //将窗口锁定
-(void) preferences; //显示偏好设置


// loader 部分的函数
-(void) ready;


-(void) error:(NSString*)detail;
-(void) signal:(NSString*)s;

-(NSString*) authKey;
-(NSNumber*) channel;
-(void) channel:(NSNumber*)n;
-(NSDictionary *) nowplaying;

-(void) loadRequest:(NSURL*) url;

-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame;
-(void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame;

+(BOOL) isSelectorExcludedFromWebScript:(SEL)selector;

@end

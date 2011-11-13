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
    NSMutableDictionary* _nowplaying;
    NSRect _show;
    NSRect _hide;
}
@property(nonatomic,retain) WebView* webview;

-(BOOL) canBecomeKeyWindow;


-(void) hide;
-(void) show;
-(void) wake;
-(void) die;




// loader 部分的函数
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

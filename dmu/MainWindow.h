//
//  MainWindow.h
//  dmu
//
//  Created by Shanzi on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#import "DomiLoader.h"

@interface MainWindow : NSWindow
{
@protected
    WebView* webview;
    DomiLoader* loader;
    NSRect _show;
    NSRect _hide;
}
@property(nonatomic,retain) WebView* webview;

-(BOOL) canBecomeKeyWindow;


-(void) hide;
-(void) show;
-(void) wake;
-(void) die;

@end

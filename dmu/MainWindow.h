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

    NSButton* _exit;
    NSRect _show;
    NSRect _hide;
}
@property(nonatomic,retain) WebView* webview;
@property(nonatomic,retain) NSImageView* quickMsgBox;



-(BOOL) canBecomeKeyWindow;

-(void) hide;
-(void) show;
-(void) wake;
-(void) die;


@end

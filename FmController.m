//
//  FmView.m
//  dmu
//
//  Created by Shanzi on 11-10-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "FmController.h"

@implementation FmController

- (id)init
{
    self = [super init];
    if (self) {
        webview=[[[WebView alloc] initWithFrame:NSMakeRect(0,0, 210, 345) frameName:@"dmu" groupName:@"dmu"]retain];
        [webview display];
        [[webview mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"douban"]]]];
        
        
    }
    
    return self;
}
- (WebView*) webView
{
    return webview;
}

@end

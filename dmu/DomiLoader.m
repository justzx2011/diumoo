//
//  DomiLoader.m
//  dmu
//
//  Created by Shanzi on 11-11-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DomiLoader.h"

@implementation DomiLoader

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        status=INIT_APP;
        webviewInstance=nil;
        _nowplaying=[[NSMutableDictionary alloc] initWithObjectsAndKeys:nil,@"title",nil,@"artist",nil,@"album_title",nil,@"album_year",nil,@"album_img_url", nil];
        actionForMusicChanged=nil;
    }
    return self;
}

-(void)dealloc
{
    [webviewInstance release];
    [super dealloc];
}

- (id) initWithWebview:(WebView *)wb
{
    self=[self init];
    webviewInstance=[wb retain];
    [webviewInstance setFrameLoadDelegate:self];
    return self;
}

-(NSString*) authKey
{
    return [NSString stringWithFormat:@"({'email':'%s','pass':'%s'})","airobot1@163.com","akirasphere"];
}

-(NSNumber*) channel
{
    return [[webviewInstance windowScriptObject] evaluateWebScript:@"channel();"];
}
-(void) channel:(NSNumber *)n
{
    [[webviewInstance windowScriptObject] evaluateWebScript:[NSString stringWithFormat:@"channel(%d);",[n intValue]]];
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
-(void) setActionForMusicChanged:(SEL)s
{
    actionForMusicChanged=s;
}
-(void) loadRequest:(NSURL*)url
{
    [[webviewInstance mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
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

//
//  FmView.h
//  dmu
//
//  Created by Shanzi on 11-10-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebView.h>


@interface FmController : NSObject
{
    NSMutableDictionary* config;
    WebView* webview;
}

-(WebView*) webView;

//-(id) initWithConfig:(NSDictionary*) config;

//-(NSArray*) play; //开始播放音乐，返回当前音乐的信息
//-(void) pause;
//-(void) next;
//-(void) likeCurrentMusic;
//-(void) unlikeCurrentMusic;

//获取当前播放中的歌曲信息
//-(void) currentMusicData;


//与webkit里的JavaScript交互的方法
//-(void) receiveJavaScriptSignal; // 接收到JavaScript发出的消息的控制函数


@end

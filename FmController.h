//
//  FmController.h
//  dmu
//
//  Created by Shanzi on 11-10-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>

@protocol FmController <NSObject>
@public
// 基本控制方法
-(NSArray*) play; //开始播放音乐，返回当前音乐的信息
-(void) pause;
-(void) next;
-(void) likeCurrentMusic;
-(void) unlikeCurrentMusic;

//获取当前播放中的歌曲信息
-(void) currentMusicData;

@private
//与webkit里的JavaScript交互的方法
-(void) receiveJavaScriptSignal; // 接收到JavaScript发出的消息的控制函数
-(void) sendJavaScriptSignal: (NSString*) signal withKeyedArguments: (NSArray*); // 向

@optional
@public
-(void) back;
@end

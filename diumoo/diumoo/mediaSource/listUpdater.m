//
//  listUpdater.m
//  diumoo
//
//  Created by Shanzi on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "listUpdater.h"
#import "CJSONDeserializer.h"
#import <Growl/Growl.h>

static NSDictionary* fetchChannelDictionary(NSTimeInterval);
static NSArray* arrayFromChannelList(NSDictionary*);
static int compareList(NSArray*,NSArray*);
static NSArray* parseChannelDictionary(NSDictionary*,NSDictionary*);

NSDictionary* fetchChannelDictionary(NSTimeInterval t){
    NSString* newliststring=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"DMU_FM_CHANNEL_LIST_URL" ];
    NSURL* newlisturl=[NSURL URLWithString:[NSString stringWithFormat:@"%@?timestamp=%f",newliststring,t]];
    NSURLRequest* newlistrequest=[NSURLRequest requestWithURL:newlisturl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1.0];
    NSURLResponse*res=nil;
    NSError* err=nil;
    NSData* data=[NSURLConnection sendSynchronousRequest:newlistrequest returningResponse:&res error:&err];
    if(err==NULL){
        NSDictionary* r=[[CJSONDeserializer deserializer] deserialize:data error:&err];
        if(err==NULL) return r;
    }
    return nil;
}

NSArray* arrayFromChannelList(NSDictionary* dic){
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"PUB_LIST_NAME", nil),@"name",
             [dic valueForKey:NSLocalizedString(@"PUB_LIST", nil)],@"sub",
             nil],
            [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"DJ_LIST_NAME", nil),@"name",
             [dic valueForKey:@"dj"],@"sub",
             nil],
             nil];
}

int compareList(NSArray* array1,NSArray* array2){
    int count=[array1 count];
    for (NSDictionary* dic in array1) {
        for (NSDictionary* dic2 in array2) {
            if([dic isEqualToDictionary:dic2]){
                count--;
                break;
            }
        }
    }
    return count;
}

NSArray* parseChannelDictionary(NSDictionary* old,NSDictionary* new){
    NSArray* old_dj_list=[old valueForKey:@"dj_list"];
    NSArray* old_pub_list=[old valueForKey:@"pub_list"];
    NSArray* new_dj_list=[new valueForKey:@"dj_list"];
    NSArray* new_pub_list=[new valueForKey:@"pub_list"];
    if(new_dj_list&&new_pub_list && [new_dj_list count]>0 && [new_pub_list count]>0){
        [new writeToFile:[[NSBundle mainBundle] pathForResource:@"channeldata" ofType:@"plist"] atomically:YES];
        int djon=compareList(old_dj_list, new_dj_list);
        int djno=compareList(new_dj_list, old_dj_list);
        int pubon=compareList(old_pub_list, new_pub_list);
        int pubno=compareList(new_pub_list, old_pub_list);
        if(djno || pubno || djon || pubon){
            NSString* noti=[NSString stringWithFormat:NSLocalizedString(@"NEW_CHANNEL_LIST", nil),pubno,pubon,djno,djon];
            [GrowlApplicationBridge notifyWithTitle:NSLocalizedString(@"NEW_CHANNEL_TITLE", nil) description:noti notificationName:@"New Channel List" iconData:nil priority:0 isSticky:NO clickContext:nil];
            return arrayFromChannelList(new);
        }
    }
    
    return arrayFromChannelList(old);

}

NSArray* getChannelList(){
    NSDictionary* old=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"channeldata" ofType:@"plist"]];
    @try {
        double timestamp=[[old valueForKey:@"timestamp"] doubleValue];
        NSDate* now = [[NSDate alloc] init];
        if(([now timeIntervalSince1970]-timestamp)>4*24*3600){
            NSDictionary* newlist=fetchChannelDictionary(timestamp);
            if(newlist){
                return parseChannelDictionary(old,newlist);
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    return arrayFromChannelList(old);
        
}
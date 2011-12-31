//
//  DetailView.m
//  diumoo
//
//  Created by Shanzi on 11-12-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DetailView.h"
#import "preference.h"

@implementation DetailView

-(id)init
{
    self = [super initWithNibName:@"DetailView.nib" bundle:nil];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAccountDetail:) name:@"source.account" object:nil];
    }
    return self;
}

-(void) awakeFromNib
{
    [album_img setImage:[NSImage imageNamed:@"album.png"]];
}

-(void) setDetail:(NSDictionary*) info withImage:(NSImage*) image
{
    NSImage* img;
    if(image!=nil)img=image;
    else img=[NSImage imageNamed:@"album.png"];


    float scale=250.0/([image size].width>[image size].height?image.size.width:image.size.height);
    if(scale<1.0)
    {
        [album_img setFrameSize:NSMakeSize(image.size.width*scale, image.size.height*scale)];
        [[self view] setFrameSize:NSMakeSize(300, [album_img frame].size.height + 150)];
    }
    else{
        [album_img setFrameSize:[img size]];
        [[self view]setFrameSize:NSMakeSize([img size].width+50,[img size].height+150)];
    }
    
    
    
    [album_img setImage:img];
    if([info valueForKey:@"Artist"]!=nil)
        [artist setStringValue:[info valueForKey:@"Artist"]];
    else [artist setStringValue:@"未知艺术家"];
    
    
    if([info valueForKey:@"Year"]!=nil) [year setStringValue:[NSString stringWithFormat:@"%@",[info valueForKey:@"Year"]]];
    else [year setStringValue:@"--"];
    
    if([info valueForKey:@"Album"]!=nil)
        [album setStringValue:[info valueForKey:@"Album"]];
    else [album setStringValue:@"未知唱片集"];
    
    if([info valueForKey:@"Name"]!=nil)
        [music setStringValue:[info valueForKey:@"Name"]];
    else [music setStringValue:@"未知歌曲"];
}

-(void) setServiceTarget:(id)t withSelector:(SEL)s
{
    target=t;
    selector=s;
}

-(void) setAccountDetail:(NSNotification*) n
{
    NSDictionary* userinfo=n.userInfo;
    if(userinfo!=nil){
        [account setImage:[NSImage imageNamed:@"account_ok.png"]];
        [account setTitle:[userinfo valueForKey:@"name"]];
        url=[[userinfo valueForKey:@"url"] retain];
    }
    else
    {
        [account setImage:[NSImage imageNamed:@"user.png"]];
        [account setTitle:@"未登录"];
        [url release];
        url=nil;
    }
    
}

-(IBAction)serviceCallback:(id)sender
{
    if([target respondsToSelector:selector]){
        NSString* s;
        switch ([sender tag]) {
            case 1:
                s=@"twitter";
                break;
            case 2:
                s=@"google";
                break;
            default:
                s=@"douban";
                break;
        }
        
        [target performSelector:selector withObject:s];
    }
        
}

-(IBAction)showAccount:(id)sender
{
    if(url==nil)[preference showPreferenceWithView:ACCOUT_PREFERENCE_ID];
    else [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

@end

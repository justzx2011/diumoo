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

-(void) setDetailReal:(NSDictionary*)dict{
    NSDictionary *info = [dict objectForKey:@"info"];
    NSImage *image = [dict objectForKey:@"image"];
    NSImage* img;
    if(image!=nil)img=image;
    else img=[NSImage imageNamed:@"album.png"];
    
    
    float scale=250.0f/([image size].width>[image size].height?image.size.width:image.size.height);
    if(scale<1.0)
    {
        [album_img setFrameSize:NSMakeSize(image.size.width*scale, image.size.height*scale)];
        [[self view] setFrameSize:NSMakeSize(300, [album_img frame].size.height + 180)];
    }
    else{
        [album_img setFrameSize:[img size]];
        [[self view]setFrameSize:NSMakeSize(300,[img size].height+180)];
    }
    
    
    
    [album_img setImage:img];
    if([info valueForKey:@"Artist"]!=nil)
        [artist setStringValue:[info valueForKey:@"Artist"]];
    else [artist setStringValue:NSLocalizedString(@"UNKNOWN_ARTIST", nil)];
    
    
    if([info valueForKey:@"Year"]!=nil) [year setStringValue:[NSString stringWithFormat:@"%@",[info valueForKey:@"Year"]]];
    else [year setStringValue:@"--"];
    
    if([info valueForKey:@"Album"]!=nil)
        [album setStringValue:[info valueForKey:@"Album"]];
    else [album setStringValue:NSLocalizedString(@"UNKNOWN_ALBUM", nil)];
    
    if([info valueForKey:@"Name"]!=nil)
        [music setStringValue:[info valueForKey:@"Name"]];
    else [music setStringValue:NSLocalizedString(@"UNKNOWN_NAME",nil)];
    
    
    @try {
        float rate=0.0f;
        if((rate=[[info valueForKey:@"Album Rating"] floatValue])>0.0)
        {
            
            int irat=(int)rate;
            [star setFrameOrigin:NSMakePoint(0, 16-30*irat-(irat<rate?15:0))];
            [rate_text setStringValue:[NSString stringWithFormat:@"%.1f",rate*2]];
            [star setHidden:NO];
            [rate_text setHidden:NO];
        }
        else {
            [star setHidden:YES];
            [rate_text setHidden:YES];
        }
    }
    @catch (NSException *exception) {
        [star setHidden:YES];
        [rate_text setHidden:YES];
    }

}

-(void) setDetail:(NSDictionary*) info withImage:(NSImage*) image
{
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:info,@"info",image,@"image", nil];
    [self performSelectorOnMainThread:@selector(setDetailReal:) withObject:dict waitUntilDone:NO];
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
        
        @try {
            if(n.object!=nil){
                NSImage* iconImage=[[[NSImage alloc] initWithData:n.object] retain];
                if(![iconImage isValid]) @throw [NSException exceptionWithName:@"Image Invalid" reason:@"Image Invalid" userInfo:nil];
                [account setImage:iconImage];
                [iconImage release];
            }
            else [account setImage:[NSImage imageNamed:@"account_ok.png"]];
        }
        @catch (NSException *exception) {
            [account setImage:[NSImage imageNamed:@"account_ok.png"]];
        }
        
        
        [account_name setStringValue:[userinfo valueForKey:@"name"]];
        [account_name setTextColor:[NSColor blueColor]];
        url=[[userinfo valueForKey:@"url"] retain];
    }
    else
    {
        [account setImage:[NSImage imageNamed:@"login.png"]];
        [account_name setStringValue:@"未登录"];
        [account_name setTextColor:[NSColor blackColor]];
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
            case 3:
                s=@"lastfm";
                break;
            case 4:
                s=@"fanfou";
                break;
            case 5:
                s=@"Sina";
                break;
            case 6:
                s=@"Facebook";
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

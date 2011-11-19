//
//  dmuAppDelegate.m
//  dmu
//
//  Created by Shanzi on 11-10-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "dmuAppDelegate.h"


@implementation dmuAppDelegate
@synthesize mainMenu,public_fm,dj_fm,window,account,username,password;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    statusItem=[[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    [statusItem setImage:[NSImage imageNamed:@"icon.png"]];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:mainMenu];
    
    
    
    [account setOpaque:NO];
    [account setBackgroundColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.8]];
    [account setLevel:NSModalPanelWindowLevel];
    
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"douban.email"]!=nil)
        [username setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"douban.email"]];
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"douban.email"]!=nil)
        [password setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"douban.pass"]];
    
    //NSArray* dj_dic=[NSArray arrayWithContentsOfFile:@"dj.plist"];
    
    for(NSDictionary* cate in [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"public" ofType:@"plist" ]])
    {
        [public_fm addItem:[NSMenuItem separatorItem]];
        [public_fm addItemWithTitle:[cate valueForKey:@"cate"] action:nil keyEquivalent:@""];
        for(NSDictionary* fm in [cate valueForKey:@"channels"]){
            NSMenuItem* item=[[NSMenuItem alloc]initWithTitle:[fm valueForKey:@"name"] action:@selector(channel:) keyEquivalent:@""];
            [item setTag:[[fm valueForKey:@"channel_id"] integerValue]];
            [item setIndentationLevel:1];
            [public_fm addItem:item];
        }
    }
    [public_fm removeItem:[public_fm itemAtIndex:0]];
    
    for(NSDictionary* channel in [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dj" ofType:@"plist"]])
    {
        NSMenuItem* item = [[NSMenuItem alloc]initWithTitle:[channel valueForKey:@"name"] action:@selector(channel:) keyEquivalent:@""];
        [item setTag:[[channel valueForKey:@"channel_id"]integerValue]];
        [dj_fm addItem:item];
    }
    
    [[public_fm itemWithTag:1] setState:NSOnState];
    current_channel=[public_fm itemWithTag:1];
                              
    
    [window loadRequest:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"douban"]]];
    [window makeKeyAndOrderFront:window];

}



-(void)applicationDidBecomeActive:(NSNotification *)notification
{
    [window show];
}

-(void)applicationDidResignActive:(NSNotification *)notification
{
    [window hide];
}

-(IBAction)exit:(id)sender
{
    [window exit:NO];
}

-(IBAction)showOrHideQuickbox:(id)sender
{
    [window showOrHide];
}

-(IBAction)pinQuickbox:(NSMenuItem*)sender
{
    if ([sender state]==NSOnState) {
        [window pin:NO];
        [sender setState:NSOffState];
    }
    else{
        [window pin:YES];
        [sender setState:NSOnState];
    }
}


-(IBAction)showDoubanAccountWindow:(id)sender
{

    [account makeKeyAndOrderFront:account];
}

-(IBAction)setDoubanAccount:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:[username stringValue] forKey:@"douban.email"];
    [[NSUserDefaults standardUserDefaults] setValue:[password stringValue] forKey:@"douban.pass"];
    
    [account close];
    [window reload];
}

-(IBAction)channel:(NSMenuItem*)sender
{
    if([window channel:[NSNumber numberWithInteger:[sender tag]]])
    {
        [current_channel setState:NSOffState];
        [sender setState:NSOnState];
        current_channel=sender;
    }
}

@end

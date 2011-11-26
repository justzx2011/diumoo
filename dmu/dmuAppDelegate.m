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
    
    
    for(NSDictionary* cate in [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"public" ofType:@"plist" ]])
    {
        [public_fm addItem:[NSMenuItem separatorItem]];
        [public_fm addItemWithTitle:[cate valueForKey:@"cate"] action:nil keyEquivalent:@""];
        for(NSDictionary* fm in [cate valueForKey:@"channels"]){
            NSMenuItem* item=[[NSMenuItem alloc]initWithTitle:[fm valueForKey:@"name"] action:@selector(_channel:) keyEquivalent:@""];
            [item setTag:[[fm valueForKey:@"channel_id"] integerValue]];
            [item setIndentationLevel:1];
            [public_fm addItem:item];
        }
    }
    [public_fm removeItem:[public_fm itemAtIndex:0]];
    
    
    
    for(NSDictionary* channel in [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dj" ofType:@"plist"]])
    {
        NSMenuItem* item = [[NSMenuItem alloc]initWithTitle:[channel valueForKey:@"name"] action:@selector(_channel:) keyEquivalent:@""];
        NSInteger item_channel=[[channel valueForKey:@"channel_id"]integerValue];
        [item setTag:item_channel ];
        NSMenu* submenu=[[NSMenu alloc] init];
        for (NSDictionary* sub in [channel objectForKey:@"sub"]) {
            NSMenuItem * subitem = [[NSMenuItem alloc] initWithTitle:[sub valueForKey:@"name"] action:nil keyEquivalent:@""];
            [subitem setTag:[[sub valueForKey:@"channel_id"] intValue]];
            [submenu addItem:subitem];
            [subitem setAction:@selector(_channel:)];
        }
        [item setSubmenu:submenu];
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

-(IBAction)_channel:(id)sender
{
    NSInteger channel=[sender tag];
    if ((channel > 10000 && [window dj_channel:[[sender parentItem] tag] withPid:channel])|| (channel<10000 && [window channel:channel] )  ) {
        [current_channel setState:NSOffState];
        [sender setState:NSOnState];
        current_channel=sender;
    }
}

@end

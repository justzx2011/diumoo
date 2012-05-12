//
//  menuController.m
//  diumoo
//
//  Created by Zheng Anakin on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "menuController.h"

@interface menuController ()

@end

@implementation menuController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        firstDetail=NO;
        statusItem=[[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain] ;
        [statusItem setImage:[NSImage imageNamed:@"icon.png"]];
        [statusItem setHighlightMode:YES];
        mainMenu=[[[NSMenu alloc]init] retain] ;
        [statusItem setMenu:mainMenu];
        albumItem=[[NSMenuItem alloc]init];
        [albumItem setView:[self view]];
        
        //红心电台和私人电台
        heartChannel=[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"RED_HEART_MHZ",nil) action:nil keyEquivalent:@""];
        
        privateChannel=[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"PRIVATE_MHZ",nil) action:nil keyEquivalent:@""];
        
        [heartChannel setTag:-3];
        [privateChannel setTag:0];
        
        [heartChannel setTarget:self];
        [privateChannel setTarget:self];
        
        [heartChannel setIndentationLevel:1];
        [privateChannel setIndentationLevel:1];
        
        [heartChannel setOnStateImage:[NSImage imageNamed:@"redheart.png"]];
        [heartChannel setOffStateImage:[NSImage imageNamed:@"greyheart.png"]];
        
        
        defaultChannel=nil;
        lastChannel=nil;
        
        
        prefsItem=[[NSMenuItem alloc]initWithTitle:NSLocalizedString(@"PREF", nil) action:nil keyEquivalent:@"" ];
        exit=[[NSMenuItem alloc]initWithTitle:NSLocalizedString(@"QUIT", nil) action:nil keyEquivalent:@""];
        aboutItem=[[NSMenuItem alloc]initWithTitle:NSLocalizedString(@"ABOUT", nil) action:nil keyEquivalent:@""] ;
        
        [volume useDefault];
        
        [play_pause setTag:1];
        [next setTag:2];
        [like setTag:3];
        [bye setTag:4];
        
        
        [play_pause setTarget:self];
        [play_pause setAction:@selector(buttonAction:)];
        
        [next setTarget:self];
        [next setAction:@selector(buttonAction:)];
        
        [like setTarget:self];
        [like setAction:@selector(buttonAction:)];
        
        [bye setTarget:self];
        [bye setAction:@selector(buttonAction:)];
        
        
        
        [play_pause setButtonType:NSMomentaryChangeButton];
        [next setButtonType:NSMomentaryChangeButton];
        [bye setButtonType:NSMomentaryChangeButton];
        [like setButtonType:NSToggleButton];
        [play_pause setBordered:NO];
        [next setBordered:NO];
        [like setBordered:NO];
        [bye setBordered:NO];
        
        
        [exit setAction:@selector(exitApp:)];
        [exit setTarget:self];
        
        [prefsItem setAction:@selector(showPrefs:)];
        [prefsItem setTarget:self];
        
        [aboutItem setAction:@selector(showPrefs:)];
        [aboutItem setTarget:self];
        
        //int i = 0;
        
        NSNumber* defualts_volume = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"volume"];
        [volume setValue:[defualts_volume floatValue]];
        
        [volume addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:NULL];
        
        condition=[[NSCondition alloc] init];
        
        controlCenter* c=[controlCenter sharedCenter];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_reform:) name:@"controller.sourceChanged" object:nil],
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDetail:) name:@"player.startToPlay" object:nil],
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rateChanged:) name:@"player.rateChanged" object:nil],
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enablesNotification:) name:@"source.enables" object:nil],[self setServiceTarget:c withSelector:@selector(service:)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAccountDetail:) name:@"source.account" object:nil];
        ;
        
    }
    
    return self;
}

-(void) awakeFromNib
{
    [album_img setImage:[NSImage imageNamed:@"album.png"]];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"value"]){
        NSNumber * value = [NSNumber numberWithFloat:volume.value] ;
        [[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:value forKey:@"volume"];
    }
}

-(IBAction)showPrefs:(id)sender
{
    if(sender==prefsItem) [preference showPreferenceWithView:GENERAL_PREFERENCE_ID];
    else [preference showPreferenceWithView:INFO_PREFERENCE_ID];
}


-(void) reformMenuWithSourceName:(NSString*) name channels:(NSArray*)channels andCans: (NSSet*) cans
{
    [condition lock];
    [mainMenu removeAllItems];
    [mainMenu addItem:albumItem];
    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    if(name!=nil)
        [mainMenu addItemWithTitle:name action:nil keyEquivalent:@""];
    
    if(channels!=nil)
    {
        [mainMenu addItem:heartChannel];
        [mainMenu addItem:privateChannel];
        
        [self _build_channel_menu:channels with:mainMenu andTabLength:1 ];
    }
    
    [mainMenu addItem:[NSMenuItem separatorItem]];
    [mainMenu addItem:prefsItem];
    [mainMenu addItem:aboutItem];
    [mainMenu addItem:[NSMenuItem separatorItem]];
    [mainMenu addItem:exit];
    
    [condition unlock];
    
}

-(void) _build_channel_menu:(NSArray *)dic with:(NSMenu *)menu andTabLength:(NSInteger) n
{
    NSInteger dc=[[[NSUserDefaults standardUserDefaults] valueForKey:@"PlayedChannel"] integerValue];
    for (NSDictionary* channel in dic) {
        if([channel valueForKey:@"name"]){
            NSMenuItem* mitem=[[NSMenuItem alloc] initWithTitle:[channel valueForKey:@"name"] action:nil keyEquivalent:@""];
            [mitem setIndentationLevel:n];
            if([channel valueForKey:@"channel_id"]!=nil) 
            {
                NSInteger channel_id=[[channel valueForKey:@"channel_id"]integerValue];
                [mitem setTag:channel_id],[mitem setTarget:self],[mitem setAction:@selector(channelAction:)];
                if(channel_id==dc) lastChannel=mitem;
                if(channel_id==1) defaultChannel=mitem;
            }
            
            if([channel valueForKey:@"sub"]!=nil)
            {
                NSMenu* submenu=[[NSMenu alloc] init];
                [self _build_channel_menu:[channel valueForKey:@"sub"] with:submenu andTabLength:0];
                [mitem setSubmenu:submenu];
                [submenu release];
            }
            [menu addItem:mitem];
            [mitem release];
        }
        else if([channel valueForKey:@"cate"])
        {
            [menu addItem:[NSMenuItem separatorItem]];
            NSMenuItem* sitem=[[NSMenuItem alloc] initWithTitle:[channel valueForKey:@"cate"] action:nil keyEquivalent:@""];
            [menu addItem:sitem];
            [self _build_channel_menu:[channel valueForKey:@"channels"] with:menu andTabLength:(1)];
            [sitem autorelease];
        }
    }
    if([[menu itemAtIndex:0] isSeparatorItem]) [menu removeItemAtIndex:0];
}

-(IBAction) exitApp:sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"player.paused" object:nil userInfo:nil];  
    [[NSApplication sharedApplication] terminate:nil];
}

-(void) _reform:(NSNotification*) n
{
    NSDictionary* userinfo = n.userInfo;
    [self reformMenuWithSourceName:[userinfo valueForKey:@"sourceName"] channels:[userinfo valueForKey:@"channels"]  andCans:[userinfo valueForKey:@"cans"]];
}

-(void) fireToPlayTheDefaultChannel
{
    [controlCenter  tryAuth:[preference authPrefsData]];
    NSInteger channal=[[[NSUserDefaults standardUserDefaults] valueForKey:@"PlayedChannel"] integerValue];
    
    if([heartChannel action]!=nil && [privateChannel action]!=nil && channal<=0)
    {
        switch (channal) {
            case -3:
                [self _channel_action:heartChannel];
                break;
            default:
                [self _channel_action:privateChannel];
                break;
        }
    }
    else
    {
        if(lastChannel!=nil) [self _channel_action:lastChannel];
        else [self _channel_action:defaultChannel];
    }
}



-(void) setDetail:(NSNotification *)n
{
    [condition lock];
    if(!firstDetail) firstDetail=YES;
    NSImage * image;
    if(n.object!=nil) image=n.object;
    else image=[NSImage imageNamed:@"album.png"];
    [self setDetail:n.userInfo withImage:image];
    if([[n.userInfo valueForKey:@"Like"] boolValue])
    {
        [like setState:NSOnState];
        [statusItem setImage:[NSImage imageNamed:@"icon-red.png"]];
    }
    else {
        [like setState:NSOffState];
        [statusItem setImage:[NSImage imageNamed:@"icon-red.png"]];
    }
    [condition unlock];
}



-(void) backChannelTo:(NSNumber*) c
{
    if(![[controlCenter sharedCenter] changeChannelTo:[c integerValue]])
        firstDetail=YES;
}

-(void) enablesNotification:(NSNotification *)n
{
    [condition lock];
    NSSet* enables=nil;
    if((enables=[n.userInfo valueForKey:@"enables"])==nil){ 
        [condition unlock];
        return;
    }
    
    if([enables containsObject:@"play"]) [play_pause setEnabled:YES];
    else [play_pause setEnabled:NO];
    if([enables containsObject:@"next"]) [next setEnabled:YES];
    else [next setEnabled:NO];
    if([enables containsObject:@"like"]) [like setEnabled:YES];
    else [like setEnabled:NO];
    if([enables containsObject:@"bye"]) [bye setEnabled:YES];
    else [bye setEnabled:NO];
    if([enables containsObject:@"private"]){
        [heartChannel setAction:@selector(channelAction:)];
        [privateChannel setAction:@selector(channelAction:)];
    }
    else
    {
        if([heartChannel state]==NSOnState || [privateChannel state]==NSOnState)
        {
            [self _channel_action:defaultChannel];
        }
        [heartChannel setAction:nil];
        [privateChannel setAction:nil];
    }
    [condition unlock];
}

-(void) _channel_action:(id)sender
{
    [current setState:NSOffState];
    NSMenuItem* i=current;
    if(current!=nil)
        while((i=[i parentItem])!=nil) [i setState:NSOffState];
    
    if([sender tag]>1000 && [sender submenu]!=nil && (i=[[sender submenu] itemAtIndex:0])!=nil);
    else i=sender;
    
    [i setState:NSOnState];
    current=i;
    [self performSelectorInBackground:@selector(backChannelTo:) withObject:[NSNumber numberWithInteger:[i tag]]];
    
    while((i=[i parentItem])!=nil) [i setState:NSMixedState];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:[sender tag]] forKey:@"PlayedChannel"];
}


-(IBAction)channelAction:(id)sender
{
    
    [condition lock];
    if(!firstDetail) {
        [condition unlock];
        return;
    }
    [self _channel_action:sender];
    
    [condition unlock];
}

-(IBAction)buttonAction:(id)sender
{
    [condition lock];
    NSInteger tag=[sender tag];
    controlCenter* controller=[controlCenter sharedCenter];
    switch (tag) {
        case 0:
            [controller performSelector:@selector(back) withObject:nil];
            break;
        case 1:
            [controller performSelector:@selector(play_pause) withObject:nil];
            break;
        case 2:
            [controller performSelector:@selector(skip) withObject:nil];
            break;
        case 3:
            if([like state]==NSOnState)
            {
                [controller performSelectorInBackground:@selector(rate) withObject:nil];
                [statusItem setImage:[NSImage imageNamed:@"icon-red.png"]];
            }
            else{
                [controller performSelectorInBackground:@selector(unrate) withObject:nil];
                [statusItem setImage:[NSImage imageNamed:@"icon.png"]];
            }
            break;
        case 4:
            [controller performSelector:@selector(bye) withObject:nil];
            break;
    }
    [condition unlock];
}

-(void) rateChanged:(NSNotification *)n
{
    if(n.userInfo==nil || [n.userInfo valueForKey:@"rate"]==nil ) return;
    float r = [[n.userInfo valueForKey:@"rate"] floatValue];
    if(r>0.99) 
    {
        [play_pause setImage:[NSImage imageNamed:@"pause.png"]];
        [play_pause setAlternateImage:[NSImage imageNamed:@"pause-alt.png"]];
    }
    else 
    {
        [play_pause setImage:[NSImage imageNamed:@"play.png"]];
        [play_pause setAlternateImage:[NSImage imageNamed:@"play-alt.png"]];
    }
}

-(BOOL) lightHeart
{
    if([like isEnabled]) {
        [like setState: NSOnState];
        [statusItem setImage:[NSImage imageNamed:@"icon-red.png"]];
        return YES;
        
    }
    return NO;
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
        [[self view] setFrameSize:NSMakeSize(300, [album_img frame].size.height + 220)];
    }
    else{
        [album_img setFrameSize:[img size]];
        [[self view]setFrameSize:NSMakeSize(300,[img size].height+220)];
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
            else [account setImage:[NSImage imageNamed:@"account_ok.jpg"]];
        }
        @catch (NSException *exception) {
            [account setImage:[NSImage imageNamed:@"account_ok.jpg"]];
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

-(void)dealloc
{
    [mainMenu release];
    [heartChannel release];
    [privateChannel release];
    [aboutItem release];
    [exit release];
    [prefsItem release];
    [next release];
    [play_pause release];
    [like release];
    [bye release];
    [albumItem release];
    [condition release];
    [super dealloc];
}

@end

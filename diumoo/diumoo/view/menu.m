//
//  menu.m
//  diumoo
//
//  Created by Shanzi on 11-12-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "menu.h"

@implementation menu

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        firstDetail=NO;
        
        item=[[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain] ;
        icon=[[NSImage imageNamed:@"icon.png"] retain];
        iconred=[[NSImage imageNamed:@"icon-red.png"] retain];
        [item setImage:icon];
        //[item setAlternateImage:[ NSImage imageNamed:@"icon-alt.png"]];
        [item setHighlightMode:YES];

        mainMenu=[[[NSMenu alloc]init] retain] ;
        //[mainMenu setFont:[NSFont fontWithName:@"HiraginoSansGB-W3" size:13]];

        [item setMenu:mainMenu];

        controlItem=[[NSMenuItem alloc]init];
        albumItem=[[NSMenuItem alloc]init];
        dv=[[DetailView alloc] init];
        
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

        NSRect b_rect=NSMakeRect(0, 0, ICON_WIDTH, ICON_WIDTH); 

        play_pause=[[NSButton alloc]initWithFrame:b_rect] ;
        next=[[NSButton alloc]initWithFrame:b_rect] ;
        rate=[[NSButton alloc]initWithFrame:b_rect] ;
        bye=[[NSButton alloc]initWithFrame:b_rect] ;
        volume = [[SZMTButton alloc]initWithFrame:b_rect];
        [volume useDefault];

        [play_pause setTag:1];
        [next setTag:2];
        [rate setTag:3];
        [bye setTag:4];


        [play_pause setTarget:self];
        [play_pause setAction:@selector(buttonAction:)];

        [next setTarget:self];
        [next setAction:@selector(buttonAction:)];

        [rate setTarget:self];
        [rate setAction:@selector(buttonAction:)];

        [bye setTarget:self];
        [bye setAction:@selector(buttonAction:)];

        play=[[NSImage imageNamed:@"play.png"] retain] ;
        play_alt=[[NSImage imageNamed:@"play-alt.png"] retain] ;

        pause=[[NSImage imageNamed:@"pause.png"] retain];
        pause_alt=[[NSImage imageNamed:@"pause-alt.png"] retain];

        like=[[NSImage imageNamed:@"like.png"] retain];
        unlike=[[NSImage imageNamed:@"unlike.png"] retain];



        [play_pause setImage:play];
        [next setImage:[NSImage imageNamed:@"next.png"]];
        [rate setImage:unlike];
        [bye setImage:[NSImage imageNamed:@"bye.png"]];
        [volume setImage:[NSImage imageNamed:@"speaker.png"]];
        
        

        [play_pause setButtonType:NSMomentaryChangeButton];
        [next setButtonType:NSMomentaryChangeButton];
        [bye setButtonType:NSMomentaryChangeButton];
        [rate setButtonType:NSToggleButton];


        [play_pause setAlternateImage:play_alt];
        [next setAlternateImage:[NSImage imageNamed:@"next-alt.png"]];
        [bye setAlternateImage:[NSImage imageNamed:@"bye-alt.png"]];
        [rate setAlternateImage: like];


        [play_pause setBordered:NO];
        [next setBordered:NO];
        [rate setBordered:NO];
        [bye setBordered:NO];


        controlView=[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 0,ICON_WIDTH+8)] ;
        [controlView displayIfNeeded];
        [controlItem setView:controlView];

        [albumItem setView:[dv view]];

        [exit setAction:@selector(exitApp:)];
        [exit setTarget:self];

        [prefsItem setAction:@selector(showPrefs:)];
        [prefsItem setTarget:self];

        [aboutItem setAction:@selector(showPrefs:)];
        [aboutItem setTarget:self];

        //int i = 0;
        

        [play_pause setFrameOrigin:NSMakePoint(0*ICON_WIDTH+20, 4)],[controlView addSubview:play_pause]; 
        [next setFrameOrigin:NSMakePoint(1*ICON_WIDTH+20, 4)],[controlView addSubview:next]; 
        [rate setFrameOrigin:NSMakePoint(2*ICON_WIDTH+20, 4)],[controlView addSubview:rate];
        [bye setFrameOrigin:NSMakePoint(3*ICON_WIDTH+20, 4)],[controlView addSubview:bye];
        [volume setFrameOrigin:NSMakePoint(4*ICON_WIDTH+20, 4)],[controlView addSubview:volume];
        [controlView setFrameSize:NSMakeSize(5*ICON_WIDTH+40, ICON_WIDTH+8)];
        
        NSNumber* defualts_volume = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"volume"];
        [volume setValue:[defualts_volume floatValue]];
        
        [volume addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:NULL];
        
        condition=[[NSCondition alloc] init];

        controlCenter* c=[controlCenter sharedCenter];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_reform:) name:@"controller.sourceChanged" object:nil],
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDetail:) name:@"player.startToPlay" object:nil],
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rateChanged:) name:@"player.rateChanged" object:nil],
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enablesNotification:) name:@"source.enables" object:nil],[dv setServiceTarget:c withSelector:@selector(service:)];
        ;

    }

    return self;
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

    [mainMenu addItem:controlItem];
    [mainMenu addItem:[NSMenuItem separatorItem]];
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
    [dv setDetail:n.userInfo withImage:image];
    if([[n.userInfo valueForKey:@"Like"] boolValue])
    {
        [rate setState:NSOnState];
        [item setImage:iconred];
    }
    else {
        [rate setState:NSOffState];
        [item setImage:icon];
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
    if([enables containsObject:@"like"]) [rate setEnabled:YES];
    else [rate setEnabled:NO];
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
             if([rate state]==NSOnState)
             {
                 [controller performSelectorInBackground:@selector(rate) withObject:nil];
                 [item setImage:iconred];
             }
             else{
                 [controller performSelectorInBackground:@selector(unrate) withObject:nil];
                 [item setImage:icon];
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
    if(r>0.99) [play_pause setImage:pause],[play_pause setAlternateImage:pause_alt];
    else [play_pause setImage:play],[play_pause setAlternateImage:play_alt];
}

-(BOOL) lightHeart
{
    if([rate isEnabled]) {
        [rate setState: NSOnState];
        [item setImage:iconred];
        return YES;
        
    }
    return NO;
}

-(void)dealloc
{
    [item release];
    [mainMenu release];
    [heartChannel release];
    [privateChannel release];
    [aboutItem release];
    [exit release];
    [prefsItem release];
    [controlItem release];
    [controlView release];
    [next release];
    [play_pause release];
    [pause release];
    [play release];
    [play_alt release];
    [pause_alt release];
    [like release];
    [unlike release];
    [rate release];
    [bye release];
    [albumItem release];
    [dv release];
    [icon release];
    [iconred release];
    [condition release];
    [super dealloc];
}

@end

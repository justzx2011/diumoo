//
//  preference.m
//  diumoo
//
//  Created by Shanzi on 11-12-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "preference.h"

static preference* shared;

@implementation preference

+(id) sharedPreference
{
    if(shared==nil) shared=[[[preference alloc] init] retain];
    return shared;
}

+(void) showPreferenceWithView:(NSInteger)view_id
{
    [[preference sharedPreference] selectPreferenceViewWithID:view_id];
}

-(id)init
{
    self=[super initWithWindowNibName:@"prefsPanel"];
    if(self){
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    
}

-(IBAction) selectPreferenceView:(id)sender
{
    [self selectPreferenceViewWithID:[sender tag]];
}

-(void) selectPreferenceViewWithID:(NSInteger)view_id
{
    [self showWindow:self];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    NSToolbarItem* idi=nil;
    for (NSToolbarItem* item in [toolbar items])
    {
        if([item tag]==view_id) {idi=item;break;}
        else if([item tag]==0) idi=item;
    }

    [mainview selectTabViewItemAtIndex:[idi tag]];
    [toolbar setSelectedItemIdentifier:idi.itemIdentifier];
}



-(void) dealloc
{
    shared=nil;
    [super dealloc];
}

@end

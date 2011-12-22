//
//  preference.h
//  diumoo
//
//  Created by Shanzi on 11-12-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define GENERAL_PREFERENCE_ID 0
#define ACCOUT_PREFERENCE_ID 1
#define SERVICE_PREFERENCE_ID 2
#define INFO_PREFERENCE_ID 3


@interface preference : NSWindowController
{
    
    IBOutlet NSToolbar* toolbar;
    IBOutlet NSTabView* mainview;
    
}

+(id) sharedPreference;
+(void)showPreferenceWithView:(NSInteger) view_id;

-(IBAction)selectPreferenceView:(id)sender;
-(void) selectPreferenceViewWithID:(NSInteger) view_id;

@end

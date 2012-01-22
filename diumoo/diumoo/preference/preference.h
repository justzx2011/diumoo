//
//  preference.h
//  diumoo
//
//  Created by Shanzi on 11-12-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/sparkle.h>
#import <dispatch/dispatch.h>
#import "EMKeychainItem.h"

#define GENERAL_PREFERENCE_ID 0
#define ACCOUT_PREFERENCE_ID 1
#define INFO_PREFERENCE_ID 2


@interface preference : NSWindowController
{
    
    IBOutlet NSToolbar* toolbar;
    IBOutlet NSTabView* mainview;
    IBOutlet NSTextField* email;
    IBOutlet NSSecureTextField* pass;
    IBOutlet NSTextField* captcha_input;
    IBOutlet NSButton* captcha_button;
    IBOutlet NSButton* login;
    IBOutlet NSButton* logout;
    
    IBOutlet NSButton* version;
    IBOutlet NSProgressIndicator* indicator;
    
    NSString* captcha_code;
}

@property(nonatomic,assign) NSToolbar* toolbar;
@property(nonatomic,assign) NSTabView* mainview;
@property(nonatomic,assign) NSTextField* email;
@property(nonatomic,assign) IBOutlet NSSecureTextField* pass;

+(id) sharedPreference;
+(void)showPreferenceWithView:(NSInteger) view_id;
+(NSDictionary*) authPrefsData;

-(IBAction)changeProcessType:(id)sender;
-(IBAction)selectPreferenceView:(id)sender;
-(IBAction)desktopWaveLevelChanged:(id)sender;
-(void) selectPreferenceViewWithID:(NSInteger) view_id;
-(IBAction)clearPassword:(id)sender;
-(IBAction)updatePassword:(id)sender;
-(IBAction)updateApp:(id)sender;
-(IBAction)dockAlbum:(id)sender;

-(IBAction)getCaptchaImage:(id)sender;


-(IBAction)openLink:(id)sender;

@end

//
//  preference.m
//  diumoo
//
//  Created by Shanzi on 11-12-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "preference.h"
#import "controlCenter.h"

static preference* shared;

@implementation preference

@synthesize toolbar,mainview,email,pass;

+(id) sharedPreference
{
    if(shared==nil) shared=[[[preference alloc] init] retain];
    return shared;
}

+(void) showPreferenceWithView:(NSInteger)view_id
{
    [[preference sharedPreference] selectPreferenceViewWithID:view_id];
}

+(NSDictionary*) authPrefsData
{
    NSString* username=[EMGenericKeychainItem genericKeychainItemForService:@"diumoo-music-service" withUsername:@"diumoo-username"].password;
    NSString* password=[EMGenericKeychainItem genericKeychainItemForService:@"diumoo-music-service" withUsername:@"diumoo-password"].password;
    return [NSDictionary dictionaryWithObjectsAndKeys:username,@"username",password,@"password", nil];
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
    if(view_id==ACCOUT_PREFERENCE_ID)
    {
        NSString* username=[EMGenericKeychainItem genericKeychainItemForService:@"diumoo-music-service" withUsername:@"diumoo-username"].password;
        NSString* password=[EMGenericKeychainItem genericKeychainItemForService:@"diumoo-music-service" withUsername:@"diumoo-password"].password;
        [email setStringValue:(username!=nil?username:@"")];

        [pass setStringValue:(password!=nil?password:@"")];
    }
    [mainview selectTabViewItemAtIndex:[idi tag]];
    [toolbar setSelectedItemIdentifier:idi.itemIdentifier];
}

-(IBAction)desktopWaveLevelChanged:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"preferences.desktopWaveLevelChanged" object:[sender selectedItem]];
}

-(IBAction)updatePassword:(id)sender
{
    NSString* username=[email stringValue];
    NSString* password=[pass stringValue];

    if([username length]==0 || [password length]==0)
    {
        NSRunCriticalAlertPanel(@"输入错误", @"请完整填写用户名和密码",@"取消",nil,nil);
    }
    
   else if([controlCenter tryAuth:[NSDictionary dictionaryWithObjectsAndKeys:username,@"username",password,@"password", nil]])
    {
        [EMGenericKeychainItem addGenericKeychainItemForService:@"diumoo-music-service" withUsername:@"diumoo-username" password:username];
        [EMGenericKeychainItem addGenericKeychainItemForService:@"diumoo-music-service" withUsername:@"diumoo-password" password:password];

        NSRunInformationalAlertPanel(@"登陆成功！", @"成功验证了您的账户，您现在可以记录您的播放偏好了！",@"知道了", nil, nil);
    }
    else
    {
        NSRunCriticalAlertPanel(@"认证失败", @"账户认证失败，请检查您提供的账号是否正确", @"取消", nil, nil);
    }
    
}

-(IBAction)clearPassword:(id)sender
{
    [[EMGenericKeychainItem genericKeychainItemForService:@"diumoo-music-service" withUsername:@"diumoo-username"] removeFromKeychain];
    [[EMGenericKeychainItem genericKeychainItemForService:@"diumoo-music-service" withUsername:@"diumoo-password"] removeFromKeychain];
    [email setStringValue:@""];
    [pass setStringValue:@""];
    [controlCenter cleanAuth];
    NSRunInformationalAlertPanel(@"账户记录已清除", @"已经成功将您的账户信息从系统钥匙串中清除", @"知道了", nil, nil);
}

-(IBAction)changeProcessType:(id)sender
{
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    if([sender state]==NSOnState)
    {
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    }
}

-(void) dealloc
{
    shared=nil;
    [super dealloc];
}

@end

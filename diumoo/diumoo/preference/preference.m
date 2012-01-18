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
        captcha_code=nil;
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
    [version setTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
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
    NSString* captcha=[captcha_input stringValue];
    if([username length]==0 || [password length]==0 || [captcha length]==0 || (captcha_code==nil))
    {
        NSRunCriticalAlertPanel(NSLocalizedString(@"IN_ERROR", nil),NSLocalizedString(@"PLS_FILL", nil),NSLocalizedString(@"CANCEL", nil),nil,nil);
    }
    
   else if([controlCenter tryAuth:[NSDictionary dictionaryWithObjectsAndKeys:username,@"username",password,@"password",captcha,@"captcha",captcha_code,@"captcha_code", nil]])
    {
        [EMGenericKeychainItem addGenericKeychainItemForService:@"diumoo-music-service" withUsername:@"diumoo-username" password:username];
        [EMGenericKeychainItem addGenericKeychainItemForService:@"diumoo-music-service" withUsername:@"diumoo-password" password:password];

        NSRunInformationalAlertPanel(NSLocalizedString(@"LOGIN_SUCCESS", nil), NSLocalizedString(@"VERIFY_SUCCESS", nil) , NSLocalizedString(@"KNOWN", nil) , nil, nil);
    }
    else
    {
        NSRunCriticalAlertPanel(NSLocalizedString(@"VERIFY_FAIL", nil), NSLocalizedString(@"VERIFY_FAIL_DETAIL", nil) ,NSLocalizedString(@"CANCEL", nil), nil, nil);
    }
    
}

-(IBAction)clearPassword:(id)sender
{
    [[EMGenericKeychainItem genericKeychainItemForService:@"diumoo-music-service" withUsername:@"diumoo-username"] removeFromKeychain];
    [[EMGenericKeychainItem genericKeychainItemForService:@"diumoo-music-service" withUsername:@"diumoo-password"] removeFromKeychain];
    [email setStringValue:@""];
    [pass setStringValue:@""];
    [controlCenter cleanAuth];
    NSRunInformationalAlertPanel(NSLocalizedString(@"ACCOUNT_CLEAR", nil), NSLocalizedString(@"ACCOUNT_CLEAR_DETAIL", nil), NSLocalizedString(@"KNOWN",nil) , nil, nil);
}

-(IBAction)changeProcessType:(id)sender
{
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    if([sender state]==NSOnState)
    {
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    }
}
-(IBAction)updateApp:(id)sender{
    [[SUUpdater sharedUpdater] checkForUpdates:sender];
}

-(IBAction) openLink:(id)sender
{
    switch ([sender tag]) {
        case 0:
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:ant.sz@xdlinux.info"]];
            break;
        case 1:
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://diumoo.xiuxiu.de/"]];
            break;
        case 2:
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://diumoo.xiuxiu.de/donate/"]];
            break;
        case 3:
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://diumoo.xiuxiu.de/sponsors/"]];
            break;
        default:
            break;
    }
}
-(IBAction)dockAlbum:(id)sender
{
    if([sender state]!=NSOnState){
        [NSApp setApplicationIconImage:nil];
        [[NSApp dockTile] setBadgeLabel:@""];
        [[NSApp dockTile] display];
    }
}

-(IBAction)getCaptchaImage:(id)sender
{
    dispatch_queue_t queue = dispatch_queue_create("douban.Captcha",NULL);

    [captcha_button setEnabled:NO];
    [indicator setHidden:NO];
    if(captcha_code){[captcha_code release];captcha_code=nil;}
    
    dispatch_sync(queue,^{
        NSImage* checkcode_image=nil;
        NSError* e=nil;
    NSString* code=[NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://douban.fm/j/new_captcha"] encoding:NSASCIIStringEncoding error:&e];
    if(e==NULL){
        captcha_code=[[code stringByReplacingOccurrencesOfString:@"\"" withString:@""] retain];
        checkcode_image=[[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:[@"http://douban.fm/misc/captcha?size=m&id=" stringByAppendingString:captcha_code]]];
    }
    if(e!=NULL|| checkcode_image==nil )
    {
        NSRunCriticalAlertPanel(@"获取验证码失败", @"试图从豆瓣获取验证码失败", @"知道了", nil, nil);
        [indicator setHidden:YES];
        [captcha_button setImage:nil];
        [captcha_button setTitle:@"点击获取验证码"];
        [captcha_button setEnabled:YES];
    }
    else{
        [captcha_button setTitle:@""];
        [captcha_button setImage:checkcode_image];
        [indicator setHidden:YES];
        [captcha_button setEnabled:YES];
    }
});
    

}

-(void) dealloc
{
    shared=nil;
    [super dealloc];
}

@end

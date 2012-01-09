//
//  growlNotifier.h
//  diumoo
//
//  Created by Shanzi on 11-12-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>
@interface notifier : NSObject <GrowlApplicationBridgeDelegate>

-(NSDictionary* )registrationDictionaryForGrowl;

-(void) notify:(NSNotification*)noti;
-(void) notifyAccount:(NSNotification*)noti;

-(void) growlNotification:(NSDictionary*) userinfo withImage: (id) image;
-(void) iTunesNotification:(NSDictionary*)noti;
-(void) dockNotification:(NSDictionary*)noti withImage:(id)img;

@end

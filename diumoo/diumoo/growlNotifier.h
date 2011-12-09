//
//  growlNotifier.h
//  diumoo
//
//  Created by Shanzi on 11-12-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>
@interface growlNotifier : NSObject <GrowlApplicationBridgeDelegate>

-(NSDictionary* )registrationDictionaryForGrowl;
-(void) growlNotification:(NSNotification*) noti;

@end

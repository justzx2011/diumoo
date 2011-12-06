//
//  doubanFMController.m
//  diumoo
//
//  Created by Shanzi on 11-12-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "doubanFMController.h"

@implementation doubanFMController
@synthesize request;

- (id)init
{
    self = [super init];
    if (self) {
        //初始化 request
        request=[[NSMutableURLRequest alloc]init];
        [request setTimeoutInterval:5];
        
        //初始化Connection
        connection=[[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
    }
    
    return self;
}

@end

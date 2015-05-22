//
//  BusStop.h
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-09.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusStop : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *busNo;
@property (strong, nonatomic) NSMutableArray *busesandtimes;

@property _Bool busErr;
@property _Bool expanded;
@property _Bool upToDate;
@property _Bool remove;
@end

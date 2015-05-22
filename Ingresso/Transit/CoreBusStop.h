//
//  CoreBusStop.h
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-09.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreBusStop : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * busNo;

@end

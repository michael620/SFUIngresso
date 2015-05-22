//
//  Bus.h
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-10.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bus : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *times;

@end

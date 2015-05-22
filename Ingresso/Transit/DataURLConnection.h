//
//  DataURLConnection.h
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-10.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataURLConnection : NSURLConnection
@property(nonatomic, strong) NSMutableData *data;
@property(nonatomic, copy) void (^onComplete)();

@end

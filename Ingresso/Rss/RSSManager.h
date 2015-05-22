//
//  RSSManager.h
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-15.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RSSManager : NSObject

@property (strong, atomic) NSMutableArray *allfeeds;
@property (strong, atomic) NSMutableArray *outfeeds;
@property (strong, atomic) NSMutableArray *selectedFeeds;

+(id)sharedManager;
-(void) loadFirstThreeImages;
-(void) loadRemainingImages;
-(NSMutableArray *) getFeeds;

@end

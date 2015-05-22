//
//  LibraryManager.h
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-15.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LibraryManager : NSObject

@property (strong,nonatomic) UIWebView * web;
@property (strong,nonatomic) NSMutableArray * libraryitems;
@property NSInteger numberCheckedOut;

+ (id) sharedManager;
- (void) restart;
- (void) renewSelected:(UITableView *)table;

@end

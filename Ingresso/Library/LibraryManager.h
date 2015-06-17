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
@property (strong,nonatomic) NSString * name;
@property (strong, nonatomic) NSString * login; //Family name
@property (strong, nonatomic) NSString * password; //Library barcode
@property (strong, nonatomic) NSString * action;

@property (strong, nonatomic) NSString * amountDue;
@property NSInteger numberCheckedOut;

@property BOOL signedIn, failedsignIn;

+ (id) sharedManager;
- (void) restart;
- (void) renewSelected:(UITableView *)table;
- (void) signIn;
- (void) signOut;
@end

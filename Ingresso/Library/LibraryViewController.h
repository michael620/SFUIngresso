//
//  LibraryViewController.h
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-13.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LibraryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *userButton;
@property (weak, nonatomic) IBOutlet UILabel *owingLabel;
@property (weak, nonatomic) IBOutlet UITableView *libTable;
@property (weak, nonatomic) IBOutlet UIButton *renewButton;
@property (weak, nonatomic) IBOutlet UILabel *checkedOutLabel;
@property (strong, nonatomic) IBOutlet UIWebView *web;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *amountDueLabel;


@end

//
//  libCell.h
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-15.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface libCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *bookName;
@property (weak, nonatomic) IBOutlet UITextView *warningTextView;
@property (weak, nonatomic) IBOutlet UITextView *dueDateTextView;

@property (weak, nonatomic) IBOutlet UISwitch *pick;
@end

//
//  RssCell.h
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-14.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RssCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *paddingview;
@end

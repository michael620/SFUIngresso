//
//  RssCell.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-14.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import "RssCell.h"

@implementation RssCell

@synthesize titleLabel = _titleLabel;
@synthesize imageView = _imageView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

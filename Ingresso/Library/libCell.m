//
//  libCell.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-15.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import "libCell.h"

@implementation libCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)renewSelected:(id)sender
{
    if (self.renewButton.selected == NO) {
        self.renewButton.selected = YES;
        UIImage *selected = [UIImage imageNamed:@"checkmarkRed"];
        [self.renewButton setBackgroundImage:selected forState:UIControlStateSelected];


        
    }
    else {
        self.renewButton.selected = NO;
    }

}
@end

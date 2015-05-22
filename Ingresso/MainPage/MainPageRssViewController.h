//
//  MainPageRssViewController.h
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-16.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import "ViewController.h"
#import "BannerDetailViewController.h"

@interface MainPageRssViewController : BannerDetailViewController
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *text;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property NSString *headline;
@property NSString *link;
@property UIImage *img;

@end

//
//  MainPageRssViewController.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-16.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import "MainPageRssViewController.h"
#import "RSSDetailViewController.h"

@interface MainPageRssViewController ()

@end

@implementation MainPageRssViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.image.image = _img;
    [self.button addSubview:self.image];
    self.text.text = _headline;
    self.text.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:0.7];
    self.text.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    self.text.font = [UIFont systemFontOfSize:16];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"News" bundle: nil];
   
    RSSDetailViewController *detail = [storyboard instantiateViewControllerWithIdentifier:@"RSSDetailView"];
    
    detail.url = _link;
    
    [self.navigationController pushViewController:detail animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

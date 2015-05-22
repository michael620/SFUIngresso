//
//  CoursysViewController.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-11.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import "CoursysViewController.h"
#import "ViewController.h"
@interface CoursysViewController ()

@end

@implementation CoursysViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *url = @"https://courses.cs.sfu.ca/";
    NSURL *myURL = [NSURL URLWithString: url];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL]; [self.CoursysWebView loadRequest:request];
}
- (IBAction)goBack:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ViewController * T = [storyboard instantiateViewControllerWithIdentifier:@"MainStoryboard"];
    T.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:T animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

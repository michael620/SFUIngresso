//
//  BusTimeCell.h
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-10.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusTimeCell : UITableViewCell <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) NSArray * BusNos;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@end

//
//  BusTimeCell.m
//  Ingresso
//
//  Created by Derek Cheng on 2015-05-10.
//  Copyright (c) 2015 pintMates. All rights reserved.
//

#import <sys/sysctl.h>

#import "BusTimeCell.h"
#import "Bus.h"
#import "TransitViewController.h"
@interface BusTimeCell () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) TransitViewController * transit;
@end
@implementation BusTimeCell

- (void)awakeFromNib {
    // Initialization code
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.BusNos.count;
    
}
- (IBAction)remove:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeBusStops" object:nil userInfo:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    free(machine);
    static NSString *CellIdent = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdent];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdent];
    
    //cell.textLabel.text = self.BusNos[indexPath.row];
    Bus *bus = [self.BusNos objectAtIndex:indexPath.row];
    cell.textLabel.text = [bus name];
    cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@"\t"];
    
    int c = 0;
    int count = [[bus times] count];
    for (NSString *time in [bus times])
    {
        c++;
        NSString * timeString;
        if ([time length] > 6)
            timeString = [time componentsSeparatedByString:@" "][0];
        else
            timeString = time;
        
        cell.textLabel.text = [cell.textLabel.text stringByAppendingString:timeString];
        if (c < count)
            cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@"  "];
    }

    if ([platform isEqualToString:@"iPhone3,1"] ||  [platform isEqualToString:@"iPhone3,3"] || [platform isEqualToString:@"iPhone4,1"])
    {
        cell.textLabel.font = [UIFont systemFontOfSize:10];
    }
    else if ([platform isEqualToString:@"iPhone5,1"] ||  [platform isEqualToString:@"iPhone5,2"] || [platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"] || [platform isEqualToString:@"iPhone6,1"] || [platform isEqualToString:@"iPhone6,2"] )
    {
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }

    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

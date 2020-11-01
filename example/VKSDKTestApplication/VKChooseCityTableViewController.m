//
//  VKChooseCityTableViewController.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 29.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKChooseCityTableViewController.h"
#import "VKTableViewCityCell.h"

@interface VKChooseCityTableViewController ()

@end

@implementation VKChooseCityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cities.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VKTableViewCityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];

    VKCity *city = self.cities.items[indexPath.row];
    cell.title = city.title;
    cell.isSelectedCity = (self.selectedCity == city);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate chooseCityControllerDidChooseCity:self.cities.items[indexPath.row]];

    VKTableViewCityCell *selectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.cities.items indexOfObject:self.selectedCity] inSection:0]];
    selectedCell.isSelectedCity = false;

    VKTableViewCityCell *newSelectedCell = [tableView cellForRowAtIndexPath:indexPath];

    [UIView animateWithDuration:0.3 animations:^{
        newSelectedCell.isSelectedCity = true;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:true completion:nil];
    }];


}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 52)];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.translatesAutoresizingMaskIntoConstraints = false;
    title.font = [UIFont boldSystemFontOfSize:17];
    title.text = @"Город";
    [header addSubview:title];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    button.translatesAutoresizingMaskIntoConstraints = false;
    [button setImage:[UIImage imageNamed:@"dismiss_24"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:button];

     [NSLayoutConstraint activateConstraints:@[
           [title.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
           [title.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
           [button.heightAnchor constraintEqualToConstant:48],
           [button.widthAnchor constraintEqualToConstant:48],
           [button.rightAnchor constraintEqualToAnchor:header.rightAnchor constant:-2],
           [button.centerYAnchor constraintEqualToAnchor:header.centerYAnchor]]
       ];

    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 52;
}

- (void)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end

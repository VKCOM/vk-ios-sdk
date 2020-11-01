//
//  VKTaskSevenTableTableViewController.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 24.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKTaskSevenTableViewController.h"
#import "VKChooseCityTableViewController.h"
#import "VKProductsCollectionViewController.h"
#import "VKGroupTableViewCell.h"

@interface VKTaskSevenTableViewController () <VKChooseCityTableViewControllerDelegate>

@property (nonatomic, strong) VKCitiesArray *cities;
@property (nonatomic, strong) VKGroups *groups;

@end

@implementation VKTaskSevenTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDate];

    self.navigationItem.title = @"Магазины";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dropdown_flipped_16"] style:UIBarButtonItemStyleDone target:self action:@selector(chooseCity:)];
}

- (void)setSelectedCity:(VKCity *)selectedCity {
    _selectedCity = selectedCity;
    self.navigationItem.title = [NSString stringWithFormat:@"Магазины в %@", self.selectedCity.title];
}

- (void)chooseCity:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    VKChooseCityTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VKChooseCityTableViewController"];
    vc.cities = self.cities;
    vc.selectedCity = self.selectedCity;
    vc.delegate = self;
    [self presentViewController:vc animated:true completion:nil];
}

- (void)loadDate {
    VKRequest *citiesRequest = [[VKApi database] getCitiesForCountry:1];

    [citiesRequest executeWithResultBlock:^(VKResponse *response) {
        self.cities = (VKCitiesArray *)response.parsedModel;
        self.selectedCity = self.cities.items.firstObject;
        [self loadGroups];
    } errorBlock:^(NSError *error) {
        [self showAlertWithMessage:[error description]];
    }];
}

- (void)loadGroups {
    VKRequest *groupsRequest = [[VKApi groups] searchGroupsWithMarketInCityWithId:self.selectedCity.id.integerValue count:20];

    [groupsRequest executeWithResultBlock:^(VKResponse *response) {
        self.groups = (VKGroups *)response.parsedModel;
        [self.tableView reloadData];
        [self loadIcons];
    } errorBlock:^(NSError *error) {
        [self showAlertWithMessage:[error description]];
    }];
}

- (void)loadIcons {
    for (VKGroup *group in self.groups.items) {
        if (group.photo_100 != nil) {
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:group.photo_100]
                                                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    group.image_100 = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSIndexPath *cellRow = [NSIndexPath indexPathForRow:[self.groups.items indexOfObject:group] inSection:0];
                        if ([[self.tableView indexPathsForVisibleRows] containsObject:cellRow]) {
                            VKGroupTableViewCell *cell = [self.tableView cellForRowAtIndexPath:cellRow];
                            if (cell)
                                cell.icon = group.image_100;
                        }
                    });
                }
            }];
            [task resume];
        }
    }
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];

    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VKGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell" forIndexPath:indexPath];

    VKGroup *group = self.groups.items[indexPath.row];
    cell.title = group.name;


    if (group.is_closed.integerValue == 0) {
        cell.subtitle = @"Открытая группа";
    } else if (group.is_closed.integerValue == 1) {
        cell.subtitle = @"Закрытая группа";
    } else if (group.is_closed.integerValue == 2) {
        cell.subtitle = @"Приватная группа";
    }

    if (group.image_100 != nil) {
        cell.icon = group.image_100;
    } else {

    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    VKProductsCollectionViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VKProductsCollectionViewController"];
    vc.group = self.groups.items[indexPath.row];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)chooseCityControllerDidChooseCity:(VKCity *)city {
    self.selectedCity = city;
    [self loadGroups];
}

@end

//
//  TestViewController.m
//
//  Copyright (c) 2014 VK.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TestViewController.h"

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout:)];
    self.tableView.tableFooterView = [UIView new];
}

static NSArray *labels = nil;
static NSString *const VK_CUP_TASK_1 = @"VK Cup Task 1";
static NSString *const VK_CUP_TASK_2 = @"VK Cup Task 2";
static NSString *const VK_CUP_TASK_3 = @"VK Cup Task 3";
static NSString *const VK_CUP_TASK_4 = @"VK Cup Task 4";
static NSString *const VK_CUP_TASK_5 = @"VK Cup Task 5";
static NSString *const VK_CUP_TASK_6 = @"VK Cup Task 6";
static NSString *const VK_CUP_TASK_7 = @"VK Cup Task 7";

//Fields
static NSString *const ALL_USER_FIELDS = @"id,first_name,last_name,sex,bdate,city,country,photo_50,photo_100,photo_200_orig,photo_200,photo_400_orig,photo_max,photo_max_orig,online,online_mobile,lists,domain,has_mobile,contacts,connections,site,education,universities,schools,can_post,can_see_all_posts,can_see_audio,can_write_private_message,status,last_seen,common_count,relation,relatives,counters";

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!labels)
        labels = @[VK_CUP_TASK_1, VK_CUP_TASK_2, VK_CUP_TASK_3, VK_CUP_TASK_4, VK_CUP_TASK_5, VK_CUP_TASK_6, VK_CUP_TASK_7];
    return labels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestRow"];
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    label.text = labels[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *label = labels[indexPath.row];
    if ([label isEqualToString:VK_CUP_TASK_1]) {
        [self presentTaskOneViewContoller];
    }
    else if ([label isEqualToString:VK_CUP_TASK_5]) {
        [self presentTaskFiveViewContoller];
    }
    else if ([label isEqualToString:VK_CUP_TASK_6]) {
        [self presentTaskSixViewContoller];
    }
    else if ([label isEqualToString:VK_CUP_TASK_7]) {
        [self presentTaskSevenViewContoller];
    }
}

- (void)logout:(id)sender {
    [VKSdk forceLogout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)presentTaskOneViewContoller {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VKTaskOneTableViewController"];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)presentTaskFiveViewContoller {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VKTaskFiveViewController"];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)presentTaskSixViewContoller {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VKGroupsUnsubscribeCollectionViewController"];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)presentTaskSevenViewContoller {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VKTaskSevenTableViewController"];
    [self.navigationController pushViewController:vc animated:true];
}

@end

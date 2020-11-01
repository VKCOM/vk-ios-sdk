//
//  VKGroupsUnsubscribeCollectionViewController.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 01.03.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKGroupsUnsubscribeCollectionViewController.h"
#import "VKGroupUnsubsctibeCollectionViewCell.h"
#import "VKSubscribeView.h"
#import "VKGroupInfoViewController.h"

@interface VKGroupsUnsubscribeCollectionViewController ()

@property (nonatomic, strong) VKGroups *groups;
@property (nonatomic, strong) NSMutableArray *selectedGroups;
@property (nonatomic, strong) IBOutlet UIView *subscribeView;
@property (nonatomic, weak) IBOutlet UILabel *counterLabel;

@end

@implementation VKGroupsUnsubscribeCollectionViewController

static NSString * const reuseIdentifier = @"VKGroupUnsubsctibeCollectionViewCell";

- (void)dealloc {
    [self.subscribeView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Отписаться от сообществ";
    //[self.navigationItem setPrompt:@"Коснитесь и удерживайте, чтобы увидеть информацию о сообществе"];
    [self.navigationController.navigationBar setValue:@(true) forKey:@"hidesShadow"];

    [self.collectionView registerClass:[UIView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderViewIdentifier"];
    self.selectedGroups = [NSMutableArray array];

    UIWindow* window = [UIApplication sharedApplication].keyWindow;

    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }

    [window.rootViewController.view addSubview:self.subscribeView];
    [window.rootViewController.view bringSubviewToFront:self.subscribeView];

    if (@available(iOS 11.0, *)) {
        self.subscribeView.frame = CGRectMake(0, self.view.frame.size.height - 68 - window.rootViewController.view.safeAreaInsets.bottom, self.collectionView.frame.size.width, 168);
    } else {
        self.subscribeView.frame = CGRectMake(0, self.view.frame.size.height - 68, self.collectionView.frame.size.width, 168);
    }

    self.subscribeView.hidden = true;

    [self loadData];
}

- (void)loadData {
    VKRequest *groupListRequest = [[VKApi groups] getExtended];

    [groupListRequest executeWithResultBlock:^(VKResponse *response) {
        self.groups = (VKGroups *)response.parsedModel;
        self.groups.items = [NSMutableArray arrayWithArray:[[self.groups.items reverseObjectEnumerator] allObjects]];
        [self.collectionView reloadData];
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
                        if ([[self.collectionView indexPathsForVisibleItems] containsObject:cellRow]) {
                            VKGroupUnsubsctibeCollectionViewCell *cell = (VKGroupUnsubsctibeCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:cellRow];
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.groups.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VKGroupUnsubsctibeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    VKGroup *group = self.groups.items[indexPath.row];
    cell.title = group.name;
    cell.icon = group.image_100;

    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureHandler:)];
    [longPressGesture setMinimumPressDuration:1.5];
    [cell addGestureRecognizer:longPressGesture];
    
    return cell;
}

- (void)longGestureHandler:(UISwipeGestureRecognizer *)gesture {
    self.collectionView.userInteractionEnabled = false;
    VKGroupUnsubsctibeCollectionViewCell *cell = (VKGroupUnsubsctibeCollectionViewCell *)[gesture view];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    VKGroupInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VKGroupInfoViewController"];
    vc.group = self.groups.items[[self.collectionView indexPathForCell:cell].row];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:true completion:nil];
    self.collectionView.userInteractionEnabled = true;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{

    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                         UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];

    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    VKGroup *group = self.groups.items[indexPath.row];
    VKGroupUnsubsctibeCollectionViewCell *cell = (VKGroupUnsubsctibeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    if ([self.selectedGroups containsObject:group]) {
        cell.isGroupSelected = false;
        [self.selectedGroups removeObject:group];
    } else {
        cell.isGroupSelected = true;
        [self.selectedGroups addObject:group];
    }

    self.counterLabel.text = [NSString stringWithFormat:@"%@", @(self.selectedGroups.count)];
    self.subscribeView.hidden = !(self.selectedGroups.count > 0);
}

#pragma mark <UICollectionViewDelegate>

- (IBAction)usubscribeButtonTapped:(UIButton *)sender {
    NSMutableArray *groupToRemove = [NSMutableArray arrayWithArray:self.selectedGroups];

    for (VKGroup *group in groupToRemove) {
        VKRequest *leaveRequest = [[VKApi groups] leaveGroupWithId:group.id.integerValue];

        [leaveRequest executeWithResultBlock:^(VKResponse *response) {
            [self.selectedGroups removeObject:group];

            if (self.selectedGroups.count == 0) {
                [self loadData];
            }
        } errorBlock:^(NSError *error) {
            [self showAlertWithMessage:[error description]];

            [self loadData];
        }];
    }
}

@end

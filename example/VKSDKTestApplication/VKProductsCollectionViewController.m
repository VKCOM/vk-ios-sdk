//
//  VKProductsCollectionViewController.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 29.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKProductsCollectionViewController.h"
#import "VKProductCollectionViewCell.h"
#import "VKProductViewController.h"

@interface VKProductsCollectionViewController ()

@property (nonatomic, strong) VKMarkets *markets;

@end

@implementation VKProductsCollectionViewController

static NSString * const reuseIdentifier = @"VKProductCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"Товары сообщества %@", self.group.name];
    [self.navigationController.navigationBar setValue:@(true) forKey:@"hidesShadow"];

    [self loadData];
}

- (void)loadData {
    VKRequest *marketRequest = [[VKApi market] marketProductsForCommunityWithId:-self.group.id.integerValue];

    [marketRequest executeWithResultBlock:^(VKResponse *response) {
        self.markets = (VKMarkets *)response.parsedModel;
        [self.collectionView reloadData];
        [self loadIcons];
    } errorBlock:^(NSError *error) {
        [self showAlertWithMessage:[error description]];
    }];
}

- (void)loadIcons {
    for (VKMarket *market in self.markets.items) {
        if (market.thumb_photo != nil) {
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:market.thumb_photo]
                                                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    market.preview = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSIndexPath *cellRow = [NSIndexPath indexPathForRow:[self.markets.items indexOfObject:market] inSection:0];
                        if ([[self.collectionView indexPathsForVisibleItems] containsObject:cellRow]) {
                            VKProductCollectionViewCell *cell = (VKProductCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:cellRow];
                            if (cell)
                                cell.image = market.preview;
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
    return self.markets.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VKProductCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    VKMarket *item = self.markets.items[indexPath.row];

    cell.title = item.title;
    cell.image = item.preview;
    cell.price = [item.price.text stringByReplacingOccurrencesOfString:@"rub." withString:@"₽"];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    VKProductViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VKProductViewController"];
    vc.item = self.markets.items[indexPath.row];
    [self.navigationController pushViewController:vc animated:true];
}

@end

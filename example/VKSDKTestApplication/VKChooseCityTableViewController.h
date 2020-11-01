//
//  VKChooseCityTableViewController.h
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 29.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VKChooseCityTableViewControllerDelegate

- (void)chooseCityControllerDidChooseCity:(VKCity *)city;

@end

@interface VKChooseCityTableViewController : UITableViewController

@property (nonatomic, strong) VKCitiesArray *cities;
@property (nonatomic, strong) VKCity *selectedCity;

@property (nonatomic, weak) id <VKChooseCityTableViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

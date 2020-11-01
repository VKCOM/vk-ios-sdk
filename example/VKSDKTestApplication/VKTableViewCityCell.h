//
//  VKTableViewCityCell.h
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 29.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKTableViewCityCell : UITableViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL isSelectedCity;

@end

NS_ASSUME_NONNULL_END

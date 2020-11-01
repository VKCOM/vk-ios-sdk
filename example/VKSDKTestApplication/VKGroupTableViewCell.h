//
//  VKGroupTableViewCell.h
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 01.03.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKGroupTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) UIImage *icon;

@end

NS_ASSUME_NONNULL_END

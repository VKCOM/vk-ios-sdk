//
//  VKProductCollectionViewCell.h
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 29.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKProductCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *price;

@end

NS_ASSUME_NONNULL_END

//
//  VKGroupUnsubsctibeCollectionViewCell.h
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 01.03.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKGroupUnsubsctibeCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, assign) BOOL isGroupSelected;
@property (nonatomic, strong) UILongPressGestureRecognizer *longTapRecognizer;

@end

NS_ASSUME_NONNULL_END

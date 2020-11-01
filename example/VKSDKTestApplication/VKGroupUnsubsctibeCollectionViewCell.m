//
//  VKGroupUnsubsctibeCollectionViewCell.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 01.03.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKGroupUnsubsctibeCollectionViewCell.h"

@interface VKGroupUnsubsctibeCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedIconImageView;

@end

@implementation VKGroupUnsubsctibeCollectionViewCell

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setIcon:(UIImage *)icon {
    self.iconImageView.image = icon;
}

- (void)setIsGroupSelected:(BOOL)isGroupSelected {
    self.selectedIconImageView.hidden = !isGroupSelected;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.selectedIconImageView.hidden = true;
    [self removeGestureRecognizer:self.longTapRecognizer];
}

@end

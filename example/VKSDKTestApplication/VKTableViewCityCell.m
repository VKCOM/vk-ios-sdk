//
//  VKTableViewCityCell.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 29.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKTableViewCityCell.h"

@interface VKTableViewCityCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

@end

@implementation VKTableViewCityCell

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setIsSelectedCity:(BOOL)isSelectedCity {
    self.selectedImageView.hidden = !isSelectedCity;

    if (isSelectedCity) {
        self.selectedImageView.layer.affineTransform = CGAffineTransformMakeScale(1.2, 1.2);
        [UIView animateWithDuration:0.3 animations:^{
            self.selectedImageView.layer.affineTransform = CGAffineTransformIdentity;
        }];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.selectedImageView.hidden = true;
}

@end

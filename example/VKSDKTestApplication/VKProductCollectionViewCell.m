//
//  VKProductCollectionViewCell.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 29.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKProductCollectionViewCell.h"

@interface VKProductCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation VKProductCollectionViewCell

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setPrice:(NSString *)price {
    self.priceLabel.text = price;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

@end

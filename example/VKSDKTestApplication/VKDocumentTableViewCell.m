//
//  VKDocumentTableViewCell.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 18.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKDocumentTableViewCell.h"

@interface VKDocumentTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tagIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (weak, nonatomic) IBOutlet UIView *tagsView;

@end

@implementation VKDocumentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.tagsView.hidden = true;
    self.delegate = nil;
}

#pragma mark - Public

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setSubtitle:(NSString *)subtitle {
    self.subtitleLabel.text = subtitle;
}

- (void)setTags:(NSString *)tags {
    self.tagsView.hidden = false;
    self.tagLabel.text = tags;
}

- (void)setIcon:(UIImage *)icon {
    self.iconImageView.image = icon;
}

- (UIView *)buttonView {
    return self.optionsButton;
}

#pragma mark - Delegate

- (IBAction)optionsButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(documentCell:didTappedOptionsForDocId:)]) {
        [self.delegate documentCell:self didTappedOptionsForDocId:self.documentId];
    }
}

@end

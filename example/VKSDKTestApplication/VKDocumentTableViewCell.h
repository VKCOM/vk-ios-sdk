//
//  VKDocumentTableViewCell.h
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 18.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VKDocumentTableViewCell;

@protocol VKDocumentTableViewCellDelegate <NSObject>

- (void)documentCell:(VKDocumentTableViewCell *)cell didTappedOptionsForDocId:(NSInteger)documentId;

@end

@interface VKDocumentTableViewCell : UITableViewCell

@property (nonatomic, assign) NSInteger documentId;
@property (nonatomic, weak) NSString *title;
@property (nonatomic, weak) NSString *subtitle;
@property (nonatomic, weak) NSString *tags;
@property (nonatomic, weak) UIImage *icon;

@property (nonatomic, weak, readonly) UIView *buttonView;

@property (nonatomic, weak) id <VKDocumentTableViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

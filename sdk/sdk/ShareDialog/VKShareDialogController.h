//
//  VKShareDialogController.h
//  sdk
//
//  Created by Roman Truba on 16.07.14.
//  Copyright (c) 2014 VK. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * Creates dialog for sharing some information from your app to user wall in VK
 */
@interface VKShareDialogController : UIViewController
/// Array of prepared VKUploadImage objects for upload and share. User can remove any attachment
@property (nonatomic, strong) NSArray  *uploadImages;

/// Other attachments, defined as array strings. Now supported only links
@property (nonatomic, strong) NSArray  *otherAttachmentsStrings;

/// Text to share. User can change it
@property (nonatomic, strong) NSString *text;

/// You can post not only on user wall, but also his friends walls and groups walls
@property (nonatomic, strong) NSNumber *ownerId;

/**
 Correctly presents current view controller in another
 @param viewController Parent view controller
 */
- (void)presentIn:(UIViewController *)viewController;
@end

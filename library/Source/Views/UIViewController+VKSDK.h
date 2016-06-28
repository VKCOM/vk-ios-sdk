//
//  UIViewController+VKSDK.h
//  VK-ios-sdk
//
//  Created by Roman Truba on 28.06.16.
//  Copyright © 2016 VK. All rights reserved.
//


@interface UIViewController (VKController)

- (void)vks_presentViewControllerThroughDelegate;

- (void)vks_viewControllerWillDismiss;

- (void)vks_viewControllerDidDismiss;

@end
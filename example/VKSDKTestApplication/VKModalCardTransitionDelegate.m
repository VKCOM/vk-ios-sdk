//
//  VKModalCardTransitionDelegate.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 23.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKModalCardTransitionDelegate.h"
#import "VKTaskFiveContentPickerViewController.h"
#import "VKTaskFiveViewController.h"

@interface PresentAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@end

@implementation PresentAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    VKTaskFiveContentPickerViewController* toViewController = (VKTaskFiveContentPickerViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    VKTaskFiveViewController* fromViewController = (VKTaskFiveViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;

    toViewController.view.transform = CGAffineTransformMakeTranslation(0, UIScreen.mainScreen.bounds.size.height / 2);
    fromViewController.fadeView.alpha = 0.0;
    fromViewController.fadeView.hidden = false;

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.alpha = 1.0;
        fromViewController.fadeView.alpha = 0.4;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];

    }];
}

@end

@interface DissmissAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@end

@implementation DissmissAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    VKTaskFiveViewController* toViewController = (VKTaskFiveViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
        toViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end

@implementation VKModalCardTransitionDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return PresentAnimator.new;
}


- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return DissmissAnimator.new;
}

@end

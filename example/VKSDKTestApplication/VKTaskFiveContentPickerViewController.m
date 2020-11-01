//
//  VKTaskFiveContentPickerViewController.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 23.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKTaskFiveContentPickerViewController.h"
#import "VKModalCardTransitionDelegate.h"

@import UIKit;

@interface VKTaskFiveContentPickerViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentBottomConstraint;

@property (nonatomic, assign) CGFloat keyboardOriginY;

@end

@implementation VKTaskFiveContentPickerViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.imageView.image = self.image;
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.borderColor = [UIColor colorWithRed:225/255.0 green:227/255.0 blue:230/255.0 alpha:1.0].CGColor;
    self.textView.textContainerInset = UIEdgeInsetsMake(6.5, 12, 9.5, 12);
    [self setupTextViewPlaceholder];
    self.textView.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupTextViewPlaceholder {
    self.textView.text = @"Добавить комментарий";
    self.textView.textColor = UIColor.lightGrayColor;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.keyboardOriginY = self.view.frame.size.height - keyboardSize.height;

    self.sendButtonBottomConstraint.constant = keyboardSize.height;
    self.contentBottomConstraint.constant = keyboardSize.height;

    [UIView animateWithDuration:duration
                          delay:0
                        options:animationOptionsWithCurve(animationCurve)
                     animations:^{
        [self.view layoutSubviews];
    }
                     completion:nil];
}

static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve)
{
  return (UIViewAnimationOptions)curve << 16;
}

-(void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    self.keyboardOriginY = CGRectGetMaxY(self.view.frame);

    self.sendButtonBottomConstraint.constant = 0;
    self.contentBottomConstraint.constant = 0;

    [UIView animateWithDuration:duration
                          delay:0
                        options:animationOptionsWithCurve(animationCurve)
                     animations:^{
        [self.view layoutSubviews];

    }
                     completion:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.textColor == UIColor.lightGrayColor) {
        textView.text = nil;
        textView.textColor = UIColor.blackColor;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        [self setupTextViewPlaceholder];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.imageView.frame.origin.y + 120 > self.keyboardOriginY) {
        [self.textView setScrollEnabled:true];
    }

    if (textView.textColor == UIColor.lightGrayColor) {
        textView.text = nil;
        textView.textColor = UIColor.blackColor;
    }
}

- (IBAction)dissmissButtonTapped:(UIButton *)sender {
    self.completionBlock();
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)sendButtonTapped:(UIButton *)sender {
    VKRequest *request = [VKApi uploadWallPhotoRequest:self.image parameters:[VKImageParameters jpegImageWithQuality:0.8] userId:0 groupId:0];
        [request executeWithResultBlock:^(VKResponse *response) {
            VKPhoto *photoInfo = [(VKPhotoArray *) response.parsedModel objectAtIndex:0];
            NSString *photoAttachment = [NSString stringWithFormat:@"photo%@_%@", photoInfo.owner_id, photoInfo.id];
            VKRequest *post = [[VKApi wall] post:@{VK_API_ATTACHMENTS : photoAttachment, VK_API_MESSAGE : self.textView.text}];
            [post executeWithResultBlock:^(VKResponse *postResponse) {
                NSLog(@"Result: %@", postResponse);
                NSNumber *postId = postResponse.json[@"post_id"];

                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/wall%@_%@", photoInfo.owner_id, postId]]
                                                   options:@{}
                                         completionHandler:nil];
            }                 errorBlock:^(NSError *error) {
                [self showAlertWithMessage:[error description]];
            }];
        }                    errorBlock:^(NSError *error) {
            [self showAlertWithMessage:[error description]];
        }];
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];

    [self presentViewController:alert animated:true completion:nil];
}

@end






//
//  VKTaskFiveViewController.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 23.02.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKTaskFiveViewController.h"
#import "VKTaskFiveContentPickerViewController.h"
#import "VKModalCardTransitionDelegate.h"

@interface VKTaskFiveViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImage *pickedImage;

@property (weak, nonatomic) IBOutlet UIView *internalFadeView;

@end

@implementation VKTaskFiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {

    }
}

- (UIView *)fadeView {
    return self.internalFadeView;
}

- (IBAction)choosePhotoButtonTapped:(UIButton *)sender {
    UIImagePickerController *controller = UIImagePickerController.new;
    controller.delegate = self;
    controller.mediaTypes = @[@"public.image"];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:controller animated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    self.pickedImage = [info valueForKey:UIImagePickerControllerOriginalImage];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    VKTaskFiveContentPickerViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VKTaskFiveContentPickerViewController"];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.image = self.pickedImage;
    vc.completionBlock = ^{
        [self.navigationController setNavigationBarHidden:false animated:true];
        [UIView animateWithDuration:0.3
                         animations:^{
            self.fadeView.alpha = 0.0;
        }
                         completion:^(BOOL finished) {
            self.fadeView.hidden = true;
        }];
    };

    [picker dismissViewControllerAnimated:true completion:^{
        [self.navigationController setNavigationBarHidden:true animated:true];
        self.fadeView.alpha = 0.0;
        self.fadeView.hidden = false;
        [UIView animateWithDuration:0.3 animations:^{
            self.fadeView.alpha = 0.4;
        }];

        [self presentViewController:vc animated:true completion:nil];
    }];
}

@end

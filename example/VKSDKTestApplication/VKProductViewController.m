//
//  VKProductViewController.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 01.03.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKProductViewController.h"

@interface VKProductViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *favouriteButton;

@end

@implementation VKProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.item.title;

    self.imageView.image = self.item.preview;
    self.titleLabel.text = self.item.title;
    self.subtitleLabel.text = [self.item.price.text stringByReplacingOccurrencesOfString:@"rub." withString:@"₽"];
    self.bodyLabel.text = self.item.description;

    [self setButtonType:self.item.is_favorite];
}

- (IBAction)addFavouriteButtonTapped:(UIButton *)sender {
    sender.userInteractionEnabled = false;

    if (self.item.is_favorite) {
        VKRequest *favouriteRequest = [[VKApi favourite] removeProductFromFavourite:self.item];

        [favouriteRequest executeWithResultBlock:^(VKResponse *response) {
            self.item.is_favorite = false;
            [self setButtonType:false];
            sender.userInteractionEnabled = true;
        } errorBlock:^(NSError *error) {
            [self showAlertWithMessage:[error description]];
        }];
    } else {
        VKRequest *favouriteRequest = [[VKApi favourite] addProductToFavourite:self.item];

        [favouriteRequest executeWithResultBlock:^(VKResponse *response) {
            self.item.is_favorite = true;
            [self setButtonType:true];
            sender.userInteractionEnabled = true;
        } errorBlock:^(NSError *error) {
            [self showAlertWithMessage:[error description]];
        }];
    }
}

- (void)setButtonType:(BOOL)isFavourite {
    if (isFavourite) {
        [self.favouriteButton setTitle:@"Удалить из избранного" forState:UIControlStateNormal];
        [self.favouriteButton setTitleColor:[UIColor colorWithRed:63/255.0 green:138/225.0 blue:224/225.0 alpha:1.0] forState:UIControlStateNormal];
        [self.favouriteButton setBackgroundColor:[UIColor colorWithRed:0 green:28/225.0 blue:61/225.0 alpha:0.05]];
    } else {
        [self.favouriteButton setTitle:@"Добавить в избранное" forState:UIControlStateNormal];
        [self.favouriteButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [self.favouriteButton setBackgroundColor:[UIColor colorWithRed:73/255.0 green:134/225.0 blue:204/225.0 alpha:1.0]];
    }
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

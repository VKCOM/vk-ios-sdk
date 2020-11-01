//
//  VKGroupInfoViewController.m
//  VKSDKTestApplication
//
//  Created by Дмитрий Червяков on 01.03.2020.
//  Copyright © 2020 VK. All rights reserved.
//

#import "VKGroupInfoViewController.h"
@import SafariServices;

@interface VKGroupInfoViewController ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *followersLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastDateLabel;



@end

@implementation VKGroupInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleLabel.text = self.group.name;

    self.descriptionLabel.text = self.group.description;
}

- (IBAction)openButtonTapped:(UIButton *)sender {
    SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/club%@", @(self.group.id.integerValue)]]];
    [self presentViewController:vc animated:true completion:nil];
}

- (IBAction)dissmisButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end

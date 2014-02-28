//
//  TestViewController.m
//  VKActivity
//
//  Created by Denivip Group on 28.01.14.
//  Copyright (c) 2014 Denivip Group. All rights reserved.
//

#import "TestViewController.h"

#import "VKontakteActivity.h"


@implementation TestViewController

static NSArray *labels = nil;
static NSString *const SHARE_PHOTO = @"Share photo";

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!labels)
		labels = @[SHARE_PHOTO];
	return labels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestRow"];
	UILabel *label = (UILabel *)[cell viewWithTag:1];
	label.text = labels[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *label = labels[indexPath.row];
	if ([label isEqualToString:SHARE_PHOTO]) {
		[self sharePhoto];
	}
}

- (void)sharePhoto {
    NSArray *items = @[[UIImage imageNamed:@"example.jpg"], @"Противостояние Запада и России" , [NSURL URLWithString:@"http://vk.com/videos-29622095"]];
    VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:items
                                                        applicationActivities:@[vkontakteActivity]];
    [activityViewController setValue:@"Мировое закулисье" forKey:@"subject"];
    [activityViewController setCompletionHandler:nil];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end

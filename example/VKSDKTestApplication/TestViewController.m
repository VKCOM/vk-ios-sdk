//
//  TestViewController.m
//
//  Copyright (c) 2014 VK.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TestViewController.h"
#import "ApiCallViewController.h"

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout:)];
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getUser:(id)sender {
    VKRequest *request = [[VKApi users] get];
    [request executeWithResultBlock:^(VKResponse *response) {
        NSLog(@"Result: %@", response);
    }                    errorBlock:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (IBAction)getSubscriptions:(id)sender {
    VKRequest *request = [[VKApi users] getSubscriptions:@{VK_API_EXTENDED : @(1), VK_API_COUNT : @(100)}];
    request.secure = NO;
    [request executeWithResultBlock:^(VKResponse *response) {
        NSLog(@"Result: %@", response);

    }                    errorBlock:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

static NSArray *labels = nil;
static NSString *const USERS_GET = @"users.get";
static NSString *const FRIENDS_GET = @"friends.get";
static NSString *const FRIENDS_GET_FULL = @"friends.get with fields";
static NSString *const USERS_SUBSCRIPTIONS = @"Pavel Durov subscribers";
static NSString *const UPLOAD_PHOTO = @"Upload photo to wall";
static NSString *const UPLOAD_PHOTO_ALBUM = @"Upload photo to album";
static NSString *const UPLOAD_PHOTOS = @"Upload several photos to wall";
static NSString *const TEST_CAPTCHA = @"Test captcha";
static NSString *const CALL_UNKNOWN_METHOD = @"Call unknown method";
static NSString *const TEST_VALIDATION = @"Test validation";
static NSString *const MAKE_SYNCHRONOUS = @"Make synchronous request";
static NSString *const SHARE_DIALOG = @"Test share dialog";
static NSString *const TEST_ACTIVITY = @"Test VKActivity";
static NSString *const TEST_APPREQUEST = @"Test app request";

//Fields
static NSString *const ALL_USER_FIELDS = @"id,first_name,last_name,sex,bdate,city,country,photo_50,photo_100,photo_200_orig,photo_200,photo_400_orig,photo_max,photo_max_orig,online,online_mobile,lists,domain,has_mobile,contacts,connections,site,education,universities,schools,can_post,can_see_all_posts,can_see_audio,can_write_private_message,status,last_seen,common_count,relation,relatives,counters";

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!labels)
        labels = @[USERS_GET, USERS_SUBSCRIPTIONS, FRIENDS_GET, FRIENDS_GET_FULL, UPLOAD_PHOTO, UPLOAD_PHOTO_ALBUM, UPLOAD_PHOTOS, TEST_CAPTCHA, CALL_UNKNOWN_METHOD, TEST_VALIDATION, MAKE_SYNCHRONOUS, SHARE_DIALOG, TEST_ACTIVITY, TEST_APPREQUEST];
    return labels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestRow"];
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    label.text = labels[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *label = labels[indexPath.row];
    if ([label isEqualToString:USERS_GET]) {
//		[self callMethod:[[VKApi users] get:@{ VK_API_FIELDS : ALL_USER_FIELDS }]];
        [self callMethod:[[VKApi users] get:@{VK_API_FIELDS : @"first_name, last_name, uid, photo_100", VK_API_USER_IDS : @[@(1), @(2), @(3)]}]];
    }
    else if ([label isEqualToString:USERS_SUBSCRIPTIONS]) {
        [self callMethod:[VKRequest requestWithMethod:@"users.getFollowers" andParameters:@{VK_API_USER_ID : @"1", VK_API_COUNT : @(1000), VK_API_FIELDS : ALL_USER_FIELDS} modelClass:[VKUsersArray class]]];
    }
    else if ([label isEqualToString:UPLOAD_PHOTO]) {
        [self uploadPhoto];
    }
    else if ([label isEqualToString:UPLOAD_PHOTOS]) {
        [self uploadPhotos];
    }
    else if ([label isEqualToString:TEST_CAPTCHA]) {
        [self testCaptcha];
    }
    else if ([label isEqualToString:UPLOAD_PHOTO_ALBUM]) {
        [self uploadInAlbum];
    }
    else if ([label isEqualToString:FRIENDS_GET]) {
        [self callMethod:[[VKApi friends] get]];
    }
    else if ([label isEqualToString:FRIENDS_GET_FULL]) {
        VKRequest *friendsRequest = [[VKApi friends] get:@{VK_API_FIELDS : ALL_USER_FIELDS}];
        [self callMethod:friendsRequest];
    }
    else if ([label isEqualToString:CALL_UNKNOWN_METHOD]) {
        [self callMethod:[VKRequest requestWithMethod:@"I.am.Lord.Voldemort" andParameters:nil]];
    }
    else if ([label isEqualToString:TEST_VALIDATION]) {
        [self callMethod:[VKRequest requestWithMethod:@"account.testValidation" andParameters:nil]];
    }
    else if ([label isEqualToString:MAKE_SYNCHRONOUS]) {
        VKUsersArray *users = [self loadUsers];
        NSLog(@"users %@", users);
    }
    else if ([label isEqualToString:SHARE_DIALOG]) {


        VKShareDialogController *shareDialog = [VKShareDialogController new];
        shareDialog.text = @"This post made with #vksdk #ios";
        shareDialog.vkImages = @[@"-10889156_348122347", @"7840938_319411365", @"-60479154_333497085"];
        shareDialog.shareLink = [[VKShareLink alloc] initWithTitle:@"Super puper link, but nobody knows" link:[NSURL URLWithString:@"https://vk.com/dev/ios_sdk"]];
        [shareDialog setCompletionHandler:^(VKShareDialogController *dialog, VKShareDialogControllerResult result) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:shareDialog animated:YES completion:nil];
    }
    else if ([label isEqualToString:TEST_ACTIVITY]) {
        NSArray *items = @[[UIImage imageNamed:@"apple"], @"This post made with #vksdk activity #ios", [NSURL URLWithString:@"https://vk.com/dev/ios_sdk"]];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                initWithActivityItems:items
                applicationActivities:@[[VKActivity new]]];
        [activityViewController setValue:@"VK SDK" forKey:@"subject"];
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
        [activityViewController setCompletionWithItemsHandler:nil];
#else
        [activityViewController setCompletionHandler:nil];
#endif
        if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            UIPopoverPresentationController *popover = activityViewController.popoverPresentationController;
            popover.sourceView = self.view;
            popover.sourceRect = [tableView rectForRowAtIndexPath:indexPath];
        }
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else if ([label isEqualToString:TEST_APPREQUEST]) {
        [self callMethod:[VKRequest requestWithMethod:@"apps.sendRequest" andParameters:@{@"user_id" : @45898586, @"text" : @"Yo ho ho", @"type" : @"request", @"name" : @"I need more gold", @"key" : @"more_gold"}]];

    }
}

- (VKUsersArray *)loadUsers {
    __block VKUsersArray *users;
    VKRequest *request = [[VKApi friends] get:@{@"user_id" : @1}];
    request.waitUntilDone = YES;
    [request executeWithResultBlock:^(VKResponse *response) {
        users = response.parsedModel;
    }                    errorBlock:nil];
    return users;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"API_CALL"]) {
        ApiCallViewController *vc = [segue destinationViewController];
        vc.callingRequest = self->callingRequest;
        self->callingRequest = nil;
    }
}

- (void)callMethod:(VKRequest *)method {
    self->callingRequest = method;
    [self performSegueWithIdentifier:@"API_CALL" sender:self];
}

- (void)testCaptcha {
    VKRequest *request = [[VKApiCaptcha new] force];
    [request executeWithResultBlock:^(VKResponse *response) {
        NSLog(@"Result: %@", response);
    }                    errorBlock:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)uploadPhoto {
    VKRequest *request = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"apple"] parameters:[VKImageParameters pngImage] userId:0 groupId:60479154];
    [request executeWithResultBlock:^(VKResponse *response) {
        NSLog(@"Photo: %@", response.json);
        VKPhoto *photoInfo = [(VKPhotoArray *) response.parsedModel objectAtIndex:0];
        NSString *photoAttachment = [NSString stringWithFormat:@"photo%@_%@", photoInfo.owner_id, photoInfo.id];
        VKRequest *post = [[VKApi wall] post:@{VK_API_ATTACHMENTS : photoAttachment, VK_API_OWNER_ID : @"-60479154"}];
        [post executeWithResultBlock:^(VKResponse *postResponse) {
            NSLog(@"Result: %@", postResponse);
            NSNumber *postId = postResponse.json[@"post_id"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/wall-60479154_%@", postId]]];
        }                 errorBlock:^(NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }                    errorBlock:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)uploadPhotos {
    VKRequest *request1 = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"apple"] parameters:[VKImageParameters pngImage] userId:0 groupId:60479154];
    VKRequest *request2 = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"apple"] parameters:[VKImageParameters pngImage] userId:0 groupId:60479154];
    VKRequest *request3 = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"apple"] parameters:[VKImageParameters pngImage] userId:0 groupId:60479154];
    VKRequest *request4 = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"apple"] parameters:[VKImageParameters pngImage] userId:0 groupId:60479154];
    VKBatchRequest *batch = [[VKBatchRequest alloc] initWithRequests:request1, request2, request3, request4, nil];
    [batch executeWithResultBlock:^(NSArray *responses) {
        NSLog(@"Photos: %@", responses);
        NSMutableArray *photosAttachments = [NSMutableArray new];
        for (VKResponse *resp in responses) {
            VKPhoto *photoInfo = [(VKPhotoArray *) resp.parsedModel objectAtIndex:0];
            [photosAttachments addObject:[NSString stringWithFormat:@"photo%@_%@", photoInfo.owner_id, photoInfo.id]];
        }
        VKRequest *post = [[VKApi wall] post:@{VK_API_ATTACHMENTS : [photosAttachments componentsJoinedByString:@","], VK_API_OWNER_ID : @"-60479154"}];
        [post executeWithResultBlock:^(VKResponse *response) {
            NSLog(@"Result: %@", response);
            NSNumber *postId = response.json[@"post_id"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/wall-60479154_%@", postId]]];
        }                 errorBlock:^(NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }                  errorBlock:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)uploadInAlbum {
    VKRequest *request = [VKApi uploadAlbumPhotoRequest:[UIImage imageNamed:@"apple"] parameters:[VKImageParameters pngImage] albumId:181808365 groupId:60479154];
    [request executeWithResultBlock:^(VKResponse *response) {
        NSLog(@"Result: %@", response);
        VKPhoto *photo = [(VKPhotoArray *) response.parsedModel objectAtIndex:0];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/photo-60479154_%@", photo.id]]];
    }                    errorBlock:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)logout:(id)sender {
    [VKSdk forceLogout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end

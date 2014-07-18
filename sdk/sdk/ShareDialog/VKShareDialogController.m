//
//  VKShareDialogController.m
//  sdk
//
//  Created by Roman Truba on 16.07.14.
//  Copyright (c) 2014 VK. All rights reserved.
//

#import "VKShareDialogController.h"
#import "VKBundle.h"
#import "VKUtil.h"
#import "VKUploadImage.h"
#import "VKApi.h"
#import "VKSdk.h"

///----------------------------
/// @name Processing preview images
///----------------------------
typedef enum CornerFlag {
    CornerFlagTopLeft = 0x01,
    CornerFlagTopRight = 0x02,
    CornerFlagBottomLeft = 0x04,
    CornerFlagBottomRight = 0x08,
    CornerFlagAll = CornerFlagTopLeft | CornerFlagTopRight | CornerFlagBottomLeft | CornerFlagBottomRight
} CornerFlag;

@interface UIImage (RoundedImage)
-(UIImage *)vkRoundCornersImage:(CGFloat)cornerRadius resultSize:(CGSize) imageSize;
@end

@implementation UIImage (RoundedImage)
- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect width:(float)ovalWidth height:(float)ovalHeight toCorners:(CornerFlag)corners {
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    float fw = CGRectGetWidth(rect) / ovalWidth;
    float fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh / 2);
    if (corners & CornerFlagTopRight) {
        CGContextAddArcToPoint(context, fw, fh, fw / 2, fh, 1);
    } else {
        CGContextAddLineToPoint(context, fw, fh);
    }
    if (corners & CornerFlagTopLeft) {
        CGContextAddArcToPoint(context, 0, fh, 0, fh / 2, 1);
    } else {
        CGContextAddLineToPoint(context, 0, fh);
    }
    if (corners & CornerFlagBottomLeft) {
        CGContextAddArcToPoint(context, 0, 0, fw / 2, 0, 1);
    } else {
        CGContextAddLineToPoint(context, 0, 0);
    }
    if (corners & CornerFlagBottomRight) {
        CGContextAddArcToPoint(context, fw, 0, fw, fh / 2, 1);
    } else {
        CGContextAddLineToPoint(context, fw, 0);
    }
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

-(UIImage *)vkRoundCornersImage:(CGFloat)cornerRadius resultSize:(CGSize) imageSize {
    CGImageRef imageRef = self.CGImage;
    float imageWidth = CGImageGetWidth(imageRef);
    float imageHeight = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGRect drawRect = (CGRect){CGPointZero, imageWidth, imageHeight};
    float w = imageSize.width  * [UIScreen mainScreen].scale;
    float h = imageSize.height * [UIScreen mainScreen].scale;
    cornerRadius *= [UIScreen mainScreen].scale;
    
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, w * 4, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    if (!context) {
        CGColorSpaceRelease(colorSpace);
        return nil;
    }
    CGContextClearRect(context, CGRectMake(0, 0, w, h));
    CGColorSpaceRelease(colorSpace);
    if (!context)
        return nil;
    CGRect clipRect = CGRectMake(0, 0, w, h);
    float widthScale = w / imageWidth;
    float heightScale = h / imageHeight;
    float scale = MAX(widthScale, heightScale);
    drawRect.size.width = imageWidth * scale;
    drawRect.size.height = imageHeight * scale;
    drawRect.origin.x = (w - drawRect.size.width) / 2.0f;
    drawRect.origin.y = (h - drawRect.size.height) / 2.0f;
    [self addRoundedRectToPath:context rect:clipRect width:cornerRadius height:cornerRadius toCorners:CornerFlagAll];
    CGContextClip(context);
    
    CGContextSaveGState(context);
    CGContextDrawImage(context, drawRect, imageRef);
    CGContextRestoreGState(context);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *decompressedImage = [[UIImage alloc] initWithCGImage:decompressedImageRef];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

@end

///----------------------------
/// @name Placeholder textview for comment field
///----------------------------
/**
 * From http://stackoverflow.com/a/1704469/1271424
 * Author: Jason George
 */
@interface VKPlaceHolderTextView : UITextView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UILabel *placeHolderLabel;

-(void)textChanged:(NSNotification*)notification;

@end

@implementation VKPlaceHolderTextView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    
    if (!self.placeholderColor) {
        [self setPlaceholderColor:[UIColor lightGrayColor]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if(!self.placeholder.length) {
        return;
    }
    if (!self.text.length) {
        [[self viewWithTag:999] setHidden:NO];
    } else {
        [[self viewWithTag:999] setHidden:YES];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}
-(void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    if(placeholder.length)
    {
        if (_placeHolderLabel == nil )
        {
            UIEdgeInsets inset = self.contentInset;
            if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                inset = self.textContainerInset;
            }
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset.left + 4, inset.top, self.bounds.size.width - inset.left - inset.right,0)];
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.font = self.font;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.tag = 999;
            [self addSubview:_placeHolderLabel];
        }
        
        _placeHolderLabel.text = placeholder;
        [_placeHolderLabel sizeToFit];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if( self.text.length == 0 && placeholder.length )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
}
@end

///----------------------------
/// @name Attachment cells
///----------------------------

@interface VKPhotoAttachmentCell : UICollectionViewCell
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImageView *attachImageView;
@property (nonatomic, copy) void(^onDeleteBlock)(void);
@end

@implementation VKPhotoAttachmentCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.attachImageView             = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    self.attachImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.attachImageView];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(5, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame) - 10, 10)];
    self.progressView.hidden = YES;
    [self.contentView addSubview:self.progressView];
    
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 24, 0, 24, 24)];
    self.deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.deleteButton.showsTouchWhenHighlighted = YES;
    self.deleteButton.exclusiveTouch            = YES;
    [self.deleteButton setBackgroundImage:VKImageNamed(@"ic_deletephoto") forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.deleteButton];
    
    return self;
}
-(void)setProgress:(CGFloat)progress {
    self.progressView.hidden   = NO;
    _progress = progress;
    self.progressView.progress = progress;
}
-(void)hideProgress {
    self.progressView.hidden   = YES;
}
-(void)cancelButtonClick:(UIButton*) sender {
    if (_onDeleteBlock) {
        _onDeleteBlock();
    }
}
-(void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        self.onDeleteBlock = nil;
    }
}
@end

@interface VKOtherAttachCell : VKPhotoAttachmentCell
@property (nonatomic, strong) UILabel *attachLabel;
@end

@implementation VKOtherAttachCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.attachImageView.contentMode = UIViewContentModeScaleToFill;
    [self.deleteButton setBackgroundImage:VKImageNamed(@"ic_deleteattach") forState:UIControlStateNormal];
    
    self.attachLabel           = [[UILabel alloc] initWithFrame:CGRectMake(5, 50, CGRectGetWidth(frame) - 10, CGRectGetHeight(frame) - 50)];
    self.attachLabel.textColor = [UIColor colorWithRed:144.0f/255 green:147.0f/255 blue:153.0f/255 alpha:1.0f];
    self.attachLabel.font      = [UIFont systemFontOfSize:12];
    self.attachLabel.textAlignment = NSTextAlignmentCenter;
    self.attachLabel.numberOfLines = 2;
    self.attachLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.attachLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.attachLabel];
    
    return self;
}

@end

@interface VKUploadingAttachment : VKObject
@property (nonatomic, assign) BOOL          isUploaded;
@property (nonatomic, assign) CGSize        attachSize;
@property (nonatomic, strong) NSString      *attachmentString;
@property (nonatomic, strong) UIImage       *preview;
@property (nonatomic, strong) VKUploadImage *targetUpload;
@property (nonatomic, weak)   VKRequest     *uploadingRequest;
@end


@implementation VKUploadingAttachment
@end

///----------------------------
/// @name Share dialog main controller
///----------------------------

@interface VKPostSettings : VKObject
@property (nonatomic, strong) NSNumber *friendsOnly;
@property (nonatomic, strong) NSNumber *exportTwitter;
@property (nonatomic, strong) NSNumber *exportFacebook;
@property (nonatomic, strong) NSNumber *exportLivejournal;
@property (nonatomic, strong) NSNumber *exportInstagram;
@end
@implementation VKPostSettings
@end

@interface VKShareSettingsController : UITableViewController
@property (nonatomic, strong) VKPostSettings *currentSettings;
-(instancetype) initWithPostSettings:(VKPostSettings*) settings;
@end


static NSInteger kAttachmentsViewHeight = 90.0f;

@interface VKShareDialogController () <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, VKSdkDelegate>
@property (nonatomic, strong) IBOutlet UILabel *hintLabel;
@property (nonatomic, strong) IBOutlet VKPlaceHolderTextView *textView;
@property (nonatomic, strong) IBOutlet UICollectionView *attachmentsScrollView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UIBarButtonItem *sendButton;
@property (nonatomic, strong) NSMutableArray *attachmentsArray;
@property (nonatomic, strong) id targetOwner;
@property (nonatomic, strong) VKPostSettings *postSettings;
@property (nonatomic, assign) BOOL prepared;
@property (nonatomic, strong) id<VKSdkDelegate> originalSdkDelegate;
@end

@implementation VKShareDialogController

-(void)presentIn:(UIViewController *)viewController {
    UINavigationController * vc = [[UINavigationController alloc] initWithRootViewController:self];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
    [viewController presentViewController:vc animated:YES completion:nil];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        vc.view.superview.bounds = CGRectMake(0, 0, 600, 300);
    }
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:@"VKShareDialogController" bundle:[VKBundle vkLibraryResourcesBundle]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationController.navigationBar.barTintColor = VK_COLOR;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self resizeToInterfaceOrientation:self.interfaceOrientation];
    self.textView.editable = NO;
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 8, 0, 8);
    if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.textView.textContainerInset = insets;
    } else {
        self.textView.contentInset  = insets;
    }
    self.textView.textAlignment = NSTextAlignmentLeft;
    
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:VKLocalizedString(@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.prepared) return;
    if ([VKSdk wakeUpSession]) {
        self.loadingView.hidden = NO;
        [self.loadingView startAnimating];
        self.navigationItem.titleView = self.loadingView;
        [self prepare];
    } else {
        [self authorize:nil];
//        self.loadingView.hidden = YES;
//        self.textView.editable  = NO;
//        self.textView.textColor = [UIColor lightGrayColor];
//        self.textView.textAlignment = NSTextAlignmentCenter;
//        self.textView.text = VKLocalizedString(@"UserNotAuthorized");
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:VKLocalizedString(@"Enter") style:UIBarButtonItemStyleBordered target:self action:@selector(authorize:)];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewWillAppear:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self resizeToInterfaceOrientation:toInterfaceOrientation];
}
-(void)resizeToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation {
    CGRect bounds = self.view.bounds;
    CGFloat navigationBarH = 0;
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        navigationBarH = 64.0f;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            navigationBarH = 44.0f;
        }
    } else {
        navigationBarH = 52.0f;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            navigationBarH = 44.0f;
        }
    }
    if (VK_SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        navigationBarH = 0;
    }
    
    self.textView.frame    = CGRectMake(0, navigationBarH + 5, bounds.size.width, 90 + (self.attachmentsArray.count ? 0 : kAttachmentsViewHeight));
//    self.loadingView.frame = CGRectMake(
//                                        (CGRectGetWidth(self.textView.frame) - CGRectGetWidth(self.loadingView.frame)) / 2,
//                                        CGRectGetMinY(self.textView.frame) + (CGRectGetHeight(self.textView.frame)   - CGRectGetHeight(self.loadingView.frame)) / 2,
//                                        CGRectGetWidth(self.loadingView.frame),
//                                        CGRectGetHeight(self.loadingView.frame));
//    self.vkImage.frame     = CGRectMake(CGRectGetMinX(self.vkImage.frame), CGRectGetMinY(self.loadingView.frame), CGRectGetWidth(self.vkImage.frame), CGRectGetHeight(self.vkImage.frame));
    self.attachmentsScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.textView.frame) + 5, bounds.size.width, (self.attachmentsArray.count ? kAttachmentsViewHeight : 0));
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)prepare {
    if (!_ownerId) {
        _ownerId = @([VKSdk getAccessToken].userId.integerValue);
    }
    _postSettings = [VKPostSettings new];
    if (self.ownerId.integerValue > 0) {
        [[[VKApi users] get:@{VK_API_USER_ID : self.ownerId, VK_API_FIELDS : @"first_name_acc,can_post,sex,exports"}] executeWithResultBlock:^(VKResponse *response) {
            VKUser * user = [response.parsedModel firstObject];
            self.targetOwner = user;
            NSInteger currentUserId = [VKSdk getAccessToken].userId.integerValue;
            if (user.id.integerValue == currentUserId) {
                self.hintLabel.text = [NSString stringWithFormat:VKLocalizedString(@"NewPostHint%@"), VKLocalizedString(@"YourWall")];
                
                //Установить в 0, чтобы была возможность настройки отобразить
                _postSettings.friendsOnly           = @0;
                if (user.exports.twitter) {
                    _postSettings.exportTwitter     = @1;
                }
                if (user.exports.facebook) {
                    _postSettings.exportFacebook    = @1;
                }
                if (user.exports.instagram) {
                    _postSettings.exportInstagram   = @1;
                }
                if (user.exports.livejournal) {
                    _postSettings.exportLivejournal = @1;
                }
                [self createAttachments];
            } else {
                NSString * userHintText = [NSString stringWithFormat:VKLocalizedString(@"UserWall%@"), user.first_name_acc];
                self.hintLabel.text = [NSString stringWithFormat:VKLocalizedString(@"NewPostHint%@"), userHintText];
                if (!user.can_post.boolValue) {
                    [self denyPostingOnWall:user.first_name_acc];
                } else {
                    [self createAttachments];
                }
            }
        } errorBlock:nil];
    } else {
        self.hintLabel.text = [NSString stringWithFormat:VKLocalizedString(@"NewPostHint%@"), VKLocalizedString(@"GroupWall")];
        [[[VKApi groups] getById:@{VK_API_GROUP_IDS : @(-_ownerId.integerValue), VK_API_FIELDS : @"can_post"}] executeWithResultBlock:^(VKResponse *response) {
            VKGroup * group = [response.parsedModel firstObject];
            self.targetOwner = group;
            if (!group.can_post.boolValue) {
                [self denyPostingOnWall:group.name];
            } else {
                [self createAttachments];
            }
        } errorBlock:nil];
    }
    self.prepared = YES;

}
-(NSArray*) rightBarButtonItems {
    if (!_sendButton) {
        _sendButton = [[UIBarButtonItem alloc] initWithTitle:VKLocalizedString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(sendMessage:)];
    }
    return @[_sendButton];
    return @[_sendButton, [[UIBarButtonItem alloc] initWithImage:VKImageNamed(@"vk_settings") landscapeImagePhone:nil style:UIBarButtonItemStyleBordered target:self action:@selector(openSettings:)]] ;
}
-(void)denyPostingOnWall:(NSString*)ownerName {
    _sendButton.enabled = NO;
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = _sendButton;
    self.textView.editable  = NO;
    self.textView.textColor = [UIColor lightGrayColor];
    self.textView.text      = [NSString stringWithFormat:VKLocalizedString(@"DenyPostingOn%@Wall"), ownerName];
}


-(void) close:(id) sender {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
-(void) sendMessage:(id) sender {
    self.textView.editable  = NO;
    [self.textView endEditing:YES];
    self.navigationItem.rightBarButtonItems = nil;
    UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:activity];
    [activity startAnimating];
    
    NSMutableArray *attachStrings = [NSMutableArray arrayWithCapacity:_attachmentsArray.count];
    for (VKUploadingAttachment * attach in _attachmentsArray) {
        if (!attach.isUploaded) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self sendMessage:sender];
            });
            return;
        }
        [attachStrings addObject:attach.attachmentString];
    }
    
    VKRequest * post = [[VKApi wall] post:@{VK_API_MESSAGE : self.textView.text ? : @"",
                                            VK_API_ATTACHMENTS : [attachStrings componentsJoinedByString:@","],
                                            VK_API_OWNER_ID : self.ownerId}];
    NSMutableArray * exports = [NSMutableArray new];
    if (_postSettings.friendsOnly.boolValue)       [post addExtraParameters:@{VK_API_FRIENDS_ONLY : @1}];
    if (_postSettings.exportTwitter.boolValue)     [exports addObject:@"twitter"];
    if (_postSettings.exportFacebook.boolValue)    [exports addObject:@"facebook"];
    if (_postSettings.exportInstagram.boolValue)   [exports addObject:@"instagram"];
    if (_postSettings.exportLivejournal.boolValue) [exports addObject:@"livajournal"];
//    if (exports.count) [post addExtraParameters:@{VK_API_SERVICES : [exports componentsJoinedByString:@","]}];
    
    [post executeWithResultBlock:^(VKResponse *response) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } errorBlock:^(NSError *error) {
        self.navigationItem.rightBarButtonItem  = nil;
        self.navigationItem.rightBarButtonItems = [self rightBarButtonItems];
        self.textView.editable                  = YES;
        [self.textView becomeFirstResponder];
        [[[UIAlertView alloc] initWithTitle:nil message:VKLocalizedString(@"ErrorWhilePosting") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}
-(void) openSettings:(id) sender {
    VKShareSettingsController * vc = [[VKShareSettingsController alloc] initWithPostSettings:self.postSettings];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void) authorize:(id) sender {
    _originalSdkDelegate = [VKSdk instance].delegate;
    [VKSdk instance].delegate = self;
    [VKSdk authorize:@[VK_PER_WALL,VK_PER_GROUPS,VK_PER_PHOTOS] revokeAccess:YES];
    [VKSdk instance].delegate = _originalSdkDelegate;
}
- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController * captcha = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [self presentViewController:captcha animated:YES completion:nil];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [_originalSdkDelegate vkSdkTokenHasExpired:expiredToken];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    [_originalSdkDelegate vkSdkUserDeniedAccess:authorizationError];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [_originalSdkDelegate vkSdkReceivedNewToken:newToken];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark -Attachments
-(void) setUploadImages:(NSArray *)uploadImages {
    _uploadImages = [uploadImages filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        BOOL result = [evaluatedObject isKindOfClass:[VKUploadImage class]];
        if (!result) {
            NSLog(@"Object %@ not accepted, because it must subclass VKUploadImage", evaluatedObject);
        }
        return result;
    } ] ];
}
-(void) setOtherAttachmentsStrings:(NSArray *)otherAttachmentsStrings {
    _otherAttachmentsStrings = [otherAttachmentsStrings filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        BOOL result = [evaluatedObject isKindOfClass:[NSString class]];
        if (!result) {
            NSLog(@"Object %@ not accepted, because it must be NSString like wall1_1", evaluatedObject);
        }
        return result;
    } ] ];
}

-(void) createAttachments {
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font      = [UIFont boldSystemFontOfSize:17.0f];
    titleLabel.text      = VKLocalizedString(@"NewPost");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    self.navigationItem.rightBarButtonItems = [self rightBarButtonItems];
    self.textView.editable    = YES;
    self.textView.textColor   = [UIColor blackColor];
    self.textView.textAlignment = NSTextAlignmentLeft;
    self.textView.placeholder = VKLocalizedString(@"NewMessageText");
    self.textView.text        = self.text;
    [self.loadingView stopAnimating];
    
    
    CGFloat maxHeight = kAttachmentsViewHeight;
    self.attachmentsArray = [NSMutableArray new];
    //Attach and upload images
    for (VKUploadImage * img in _uploadImages) {
        CGSize size = img.sourceImage.size;
        size = CGSizeMake(MAX(floor(size.width * maxHeight / size.height), 50), maxHeight);
        VKUploadingAttachment * attach = [VKUploadingAttachment new];
        attach.isUploaded = NO;
        attach.attachSize = size;
        attach.targetUpload = img;
        attach.preview      = [img.sourceImage vkRoundCornersImage:10.0f resultSize:size];
        [self.attachmentsArray addObject:attach];
    }
    
    //Attach other attachments
    for (NSString *attachStr in _otherAttachmentsStrings) {
        if (![attachStr hasPrefix:@"http"]) {
            NSLog(@"Non-links attachments are not supported yet");
            return;
        }
        VKUploadingAttachment * attach = [VKUploadingAttachment new];
        attach.isUploaded = YES;
        attach.attachSize = CGSizeMake(120, 90);
        attach.attachmentString = attachStr;
        [self.attachmentsArray addObject:attach];
    }
    
    [self.attachmentsScrollView registerClass:[VKPhotoAttachmentCell class] forCellWithReuseIdentifier:@"VKPhotoAttachmentCell"];
    [self.attachmentsScrollView registerClass:[VKOtherAttachCell class]     forCellWithReuseIdentifier:@"VKOtherAttachCell"];
    self.attachmentsScrollView.delegate   = self;
    self.attachmentsScrollView.dataSource = self;
    
    if (self.attachmentsArray.count) {
        [UIView animateWithDuration:0.25 animations:^{
            [self resizeToInterfaceOrientation:self.interfaceOrientation];
        }];
    }
}

#pragma mark - UICollectionView work
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.attachmentsArray.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    VKUploadingAttachment * object = self.attachmentsArray[indexPath.item];
    return object.attachSize;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VKUploadingAttachment * attach = self.attachmentsArray[indexPath.item];
    if (attach.targetUpload) {
        VKPhotoAttachmentCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VKPhotoAttachmentCell" forIndexPath:indexPath];
        
        VKUploadImage * img = attach.targetUpload;
        cell.attachImageView.image = attach.preview;
        VKRequest * request = nil;
        if (!attach.isUploaded && !attach.uploadingRequest)
        {
            if (_ownerId.integerValue > 0) {
                request = [VKApi uploadWallPhotoRequest:img.sourceImage parameters:img.parameters userId:_ownerId.integerValue groupId:0];
            } else {
                request = [VKApi uploadWallPhotoRequest:img.sourceImage parameters:img.parameters userId:0 groupId:-(_ownerId.integerValue)];
            }
        } else {
            request = attach.uploadingRequest;
        }
        __weak VKPhotoAttachmentCell * weakCell = cell;
        [request setProgressBlock:^(VKProgressType progressType, long long bytesLoaded, long long bytesTotal) {
            if (bytesTotal < 0) {
                return;
            }
            weakCell.progress = bytesLoaded * 1.0f / bytesTotal;
        }];
        [request setCompleteBlock:^(VKResponse *res) {
            [weakCell hideProgress];
            VKPhoto * photo = [res.parsedModel firstObject];
            attach.isUploaded = YES;
            attach.attachmentString = photo.attachmentString;
            attach.uploadingRequest = nil;
        }];
        [request setErrorBlock:^(NSError *error) {
            NSLog(@"Error: %@", error.vkError);
            [self removeAttachIfExists:attach];
            attach.uploadingRequest = nil;
        }];
        if (!request.isExecuting) {
            [request start];
        }
        [cell setOnDeleteBlock:^{
            [self removeAttachIfExists:attach];
            if (attach.uploadingRequest) {
                [attach.uploadingRequest cancel];
            }
        }];
        attach.uploadingRequest = request;
        return cell;
    } else {
        VKOtherAttachCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VKOtherAttachCell" forIndexPath:indexPath];
        cell.attachImageView.image = VKImageNamed(@"img_newpostattachlink");
        cell.attachLabel.text = [NSString stringWithFormat:VKLocalizedString(@"Link%@"), attach.attachmentString];
        [cell setOnDeleteBlock:^{
            [self removeAttachIfExists:attach];
        }];
        return cell;
    }
    
    return nil;
}
-(void) removeAttachIfExists:(VKUploadingAttachment*) attach {
    NSInteger index = [self.attachmentsArray indexOfObject:attach];
    if (index != NSNotFound) {
        [self.attachmentsArray removeObject:attach];
        [self.attachmentsScrollView performBatchUpdates:^{
            [self.attachmentsScrollView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        } completion:^(BOOL finished) {
            if (!self.attachmentsArray.count) {
                [UIView animateWithDuration:0.25 animations:^{
                    [self resizeToInterfaceOrientation:self.interfaceOrientation];
                }];
            }
            [self textViewDidChange:self.textView];
        }];
    }
}
-(void)textViewDidChange:(UITextView *)textView {
    _sendButton.enabled = YES;
    if (!textView.text.length && !self.attachmentsArray.count) {
        _sendButton.enabled = NO;
    }
}
@end

static NSString * const SETTINGS_FRIENDS_ONLY   = @"FriendsOnly";
static NSString * const SETTINGS_TWITTER        = @"ExportTwitter";
static NSString * const SETTINGS_FACEBOOK       = @"ExportFacebook";
static NSString * const SETTINGS_INSTAGRAM      = @"ExportInstagram";
static NSString * const SETTINGS_LIVEJOURNAL    = @"ExportLivejournal";

@interface VKShareSettingsController ()
@property (nonatomic, strong) NSArray * rows;
@end
@implementation VKShareSettingsController

-(instancetype)initWithPostSettings:(VKPostSettings *)settings {
    self = [super init];
    self.currentSettings = settings;
    NSMutableArray * newRows = [NSMutableArray new];
    if (_currentSettings.friendsOnly)
        [newRows addObject:SETTINGS_FRIENDS_ONLY];
    if (_currentSettings.exportTwitter)
        [newRows addObject:SETTINGS_TWITTER];
    if (_currentSettings.exportFacebook)
        [newRows addObject:SETTINGS_FACEBOOK];
    if (_currentSettings.exportInstagram)
        [newRows addObject:SETTINGS_INSTAGRAM];
    if (_currentSettings.exportLivejournal)
        [newRows addObject:SETTINGS_LIVEJOURNAL];
    self.rows = newRows;
    return self;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    UISwitch *switchView;
    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchView.tintColor   = VK_COLOR;
        switchView.onTintColor = VK_COLOR;

        cell.accessoryView = switchView;
        
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    } else {
        switchView = (UISwitch *)cell.accessoryView;
    }
    NSString * currentRow = self.rows[indexPath.row];
    if ([currentRow isEqual:SETTINGS_FRIENDS_ONLY]) {
        switchView.on =  self.currentSettings.friendsOnly.boolValue;
    } else {
        if ([currentRow isEqual:SETTINGS_TWITTER]) {
            switchView.on =  self.currentSettings.exportTwitter.boolValue;
        } else if ([currentRow isEqual:SETTINGS_FACEBOOK]) {
            switchView.on =  self.currentSettings.exportFacebook.boolValue;
        } else if ([currentRow isEqual:SETTINGS_INSTAGRAM]) {
            switchView.on =  self.currentSettings.exportInstagram.boolValue;
        } else if ([currentRow isEqual:SETTINGS_LIVEJOURNAL]) {
            switchView.on =  self.currentSettings.exportLivejournal.boolValue;
        }
        if (self.currentSettings.friendsOnly.boolValue) {
            switchView.enabled = NO;
            
        } else {
            switchView.enabled = YES;
        }
    }
    cell.textLabel.text = VKLocalizedString(currentRow);
    switchView.tag = 100 + indexPath.row;
    
    return cell;
}
-(void) switchChanged:(UISwitch*) sender {
    NSString * currentRow = self.rows[sender.tag - 100];
    if ([currentRow isEqual:SETTINGS_FRIENDS_ONLY]) {
        self.currentSettings.friendsOnly    = @(sender.on);
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    } else if ([currentRow isEqual:SETTINGS_TWITTER]) {
        self.currentSettings.exportTwitter  = @(sender.on);
    } else if ([currentRow isEqual:SETTINGS_FACEBOOK]) {
        self.currentSettings.exportFacebook = @(sender.on);
    } else if ([currentRow isEqual:SETTINGS_INSTAGRAM]) {
        self.currentSettings.exportInstagram = @(sender.on);
    } else if ([currentRow isEqual:SETTINGS_LIVEJOURNAL]) {
        self.currentSettings.exportLivejournal = @(sender.on);
    }
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end



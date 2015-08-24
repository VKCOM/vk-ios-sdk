//
//  VKShareDialogController.m
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

#import "VKShareDialogController.h"
#import "VKBundle.h"
#import "VKUtil.h"
#import "VKApi.h"
#import "VKSdk.h"
#import "VKHTTPClient.h"
#import "VKHTTPOperation.h"
#import "VKSharedTransitioningObject.h"


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
- (UIImage *)vkRoundCornersImage:(CGFloat)cornerRadius resultSize:(CGSize)imageSize;
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

- (UIImage *)vkRoundCornersImage:(CGFloat)cornerRadius resultSize:(CGSize)imageSize {
    CGImageRef imageRef = self.CGImage;
    float imageWidth = CGImageGetWidth(imageRef);
    float imageHeight = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGRect drawRect = (CGRect) {CGPointZero, imageWidth, imageHeight};
    float w = imageSize.width * [UIScreen mainScreen].scale;
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
/// @name Attachment cells
///----------------------------

@interface VKPhotoAttachmentCell : UICollectionViewCell
@property(nonatomic, assign) CGFloat progress;
@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, strong) UIActivityIndicatorView *activity;
@property(nonatomic, strong) UIButton *deleteButton;
@property(nonatomic, strong) UIImageView *attachImageView;
@property(nonatomic, copy) void(^onDeleteBlock)(void);
@end

@implementation VKPhotoAttachmentCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.attachImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    self.attachImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.attachImageView];

    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(5, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame) - 10, 10)];
    self.progressView.hidden = YES;
    [self.contentView addSubview:self.progressView];

    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity.frame = CGRectMake(roundf((frame.size.width - self.activity.frame.size.width) / 2),
            roundf((frame.size.height - self.activity.frame.size.height) / 2),
            self.activity.frame.size.width,
            self.activity.frame.size.height);
    self.activity.hidesWhenStopped = YES;

    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 24, 0, 24, 24)];
    self.deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.deleteButton.showsTouchWhenHighlighted = YES;
    self.deleteButton.exclusiveTouch = YES;
    [self.deleteButton setBackgroundImage:VKImageNamed(@"ic_deletephoto") forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.contentView addSubview:self.deleteButton];

    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if (progress > 0) {
        [self addSubview:self.progressView];
        [self.activity removeFromSuperview];
        self.progressView.hidden = NO;
        self.progressView.progress = progress;
    } else {
        [self.progressView removeFromSuperview];
        if (!self.activity.superview) {
            [self addSubview:self.activity];
            [self.activity startAnimating];
        }
    }
}

- (void)hideProgress {
    self.progressView.hidden = YES;
    [self.activity stopAnimating];
    [self.activity removeFromSuperview];
}

- (void)cancelButtonClick:(UIButton *)sender {
    if (_onDeleteBlock) {
        _onDeleteBlock();
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        self.onDeleteBlock = nil;
    }
}
@end

@interface VKUploadingAttachment : VKObject
@property(nonatomic, assign) BOOL isUploaded;
@property(nonatomic, assign) BOOL isDownloading;
@property(nonatomic, assign) CGSize attachSize;
@property(nonatomic, strong) NSString *attachmentString;
@property(nonatomic, strong) UIImage *preview;
@property(nonatomic, strong) VKUploadImage *targetUpload;
@property(nonatomic, weak) VKRequest *uploadingRequest;
@end


@implementation VKUploadingAttachment
@end

///----------------------------
/// @name Privacy settings class
///----------------------------
@interface VKPostSettings : VKObject
@property(nonatomic, strong) NSNumber *friendsOnly;
@property(nonatomic, strong) NSNumber *exportTwitter;
@property(nonatomic, strong) NSNumber *exportFacebook;
@property(nonatomic, strong) NSNumber *exportLivejournal;
@end

@implementation VKPostSettings
@end

@interface VKShareSettingsController : UITableViewController
@property(nonatomic, strong) VKPostSettings *currentSettings;

- (instancetype)initWithPostSettings:(VKPostSettings *)settings;
@end

@interface VKShareDialogControllerInternal : UIViewController <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, VKSdkDelegate>
@property(nonatomic, weak) VKShareDialogController *parent;
@end

///-------------------------------
/// @name Presentation view controller for dialog
///-------------------------------

static const CGFloat ipadWidth = 500.f;
static const CGFloat ipadHeight = 500.f;

@interface VKShareDialogController ()
@end

@implementation VKShareDialogController {
    UINavigationController *_internalNavigation;
    VKSharedTransitioningObject *_transitionDelegate;
    VKShareDialogControllerInternal *_targetShareDialog;
    UIBarStyle defaultBarStyle;
}


- (instancetype)init {
    if (self = [super init]) {
        defaultBarStyle = [UINavigationBar appearance].barStyle;
        [UINavigationBar appearance].barStyle = UIBarStyleDefault;
        _internalNavigation = [[UINavigationController alloc] initWithRootViewController:_targetShareDialog = [VKShareDialogControllerInternal new]];

        _targetShareDialog.parent = self;
        _authorizeInApp = YES;

        [self addChildViewController:_internalNavigation];

        self.requestedScope = @[VK_PER_WALL, VK_PER_PHOTOS];
        if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            _transitionDelegate = [VKSharedTransitioningObject new];
            self.modalPresentationStyle = UIModalPresentationCustom;
            self.transitioningDelegate = _transitionDelegate;
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        }
        if (VK_IS_DEVICE_IPAD) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4f];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.autoresizesSubviews = NO;

    if (VK_IS_DEVICE_IPAD) {
        self.view.backgroundColor = [UIColor clearColor];
    } else {
        _internalNavigation.view.layer.cornerRadius = 10;
        _internalNavigation.view.layer.masksToBounds = YES;
    }
    [_internalNavigation beginAppearanceTransition:YES animated:NO];
    [self.view addSubview:_internalNavigation.view];
    [_internalNavigation endAppearanceTransition];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (VK_IS_DEVICE_IPAD) {
        self.view.superview.layer.cornerRadius = 10.0;
        self.view.superview.layer.masksToBounds = YES;
    }
}


- (CGSize)preferredContentSize {
    if (UIUserInterfaceIdiomPad == [[UIDevice currentDevice] userInterfaceIdiom]) {
        return CGSizeMake(ipadWidth, ipadHeight);
    }
    return [super preferredContentSize];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self rotateToInterfaceOrientation:self.interfaceOrientation appear:YES];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self rotateToInterfaceOrientation:toInterfaceOrientation appear:NO];
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)orientation appear:(BOOL)onAppear {
    if (VK_IS_DEVICE_IPAD) {
        CGSize viewSize = self.view.frame.size;
        if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            viewSize.width = ipadWidth;
            viewSize.height = ipadHeight;
        }
        _internalNavigation.view.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
        return;
    }


    static const CGFloat landscapeWidthCoef = 0.8f;
    static const CGFloat landscapeHeightCoef = 0.8f;
    static const CGFloat portraitWidthCoef = 0.9f;
    static const CGFloat portraitHeightCoef = 0.7f;


    CGSize selfSize = self.view.frame.size;
    CGSize viewSize;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        viewSize = CGSizeMake(ipadWidth, ipadHeight);
    } else {
        if (VK_SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            if (!onAppear && !UIInterfaceOrientationIsPortrait(orientation)) {
                CGFloat w = selfSize.width;
                selfSize.width = selfSize.height;
                selfSize.height = w;
            }
            if (VK_SYSTEM_VERSION_LESS_THAN(@"7.0")) {
                viewSize = selfSize;
            } else {
                if (UIInterfaceOrientationIsLandscape(orientation)) {
                    viewSize = CGSizeMake(roundf(selfSize.width * landscapeWidthCoef), roundf(selfSize.height * landscapeHeightCoef));
                } else {
                    viewSize = CGSizeMake(roundf(selfSize.width * portraitWidthCoef), roundf(selfSize.height * portraitHeightCoef));
                }
            }
        } else {
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                viewSize = CGSizeMake(roundf(selfSize.width * landscapeWidthCoef), roundf(selfSize.height * landscapeHeightCoef));
            } else {
                viewSize = CGSizeMake(roundf(selfSize.width * portraitWidthCoef), roundf(selfSize.height * portraitHeightCoef));
            }
        }
    }
    if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") || onAppear || UIInterfaceOrientationIsPortrait(orientation)) {
        _internalNavigation.view.frame = CGRectMake(roundf((CGRectGetWidth(self.view.frame) - viewSize.width) / 2),
                roundf((CGRectGetHeight(self.view.frame) - viewSize.height) / 2),
                viewSize.width, viewSize.height);
    } else if (UIInterfaceOrientationIsLandscape(orientation)) {
        _internalNavigation.view.frame = CGRectMake(roundf((CGRectGetHeight(self.view.frame) - viewSize.width) / 2),
                roundf((CGRectGetWidth(self.view.frame) - viewSize.height) / 2),
                viewSize.width, viewSize.height);
    }
    if (VK_SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        if (self.presentingViewController.modalPresentationStyle != UIModalPresentationCurrentContext) {
            CGRect frame;
            frame.origin = CGPointZero;
            frame.size = selfSize;
            _internalNavigation.view.frame = frame;
            _internalNavigation.view.layer.cornerRadius = 3;
        }
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)presentIn:(UIViewController *)viewController __deprecated {
    [viewController presentViewController:self animated:YES completion:nil];
    self.dismissAutomatically = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _internalNavigation.navigationBar.barTintColor = VK_COLOR;
        _internalNavigation.navigationBar.tintColor = [UIColor whiteColor];
        _internalNavigation.automaticallyAdjustsScrollViewInsets = NO;
    }

}

- (void)setUploadImages:(NSArray *)uploadImages {
    _uploadImages = [uploadImages filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        BOOL result = [evaluatedObject isKindOfClass:[VKUploadImage class]];
        if (!result) {
            NSLog(@"Object %@ not accepted, because it must subclass VKUploadImage", evaluatedObject);
        }
        return result;
    }]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UINavigationBar appearance].barStyle = defaultBarStyle;
}
@end


///----------------------------
/// @name Placeholder textview for comment field
///----------------------------
/**
* Author: Jason George;
* Source: http://stackoverflow.com/a/1704469/1271424
*/
@interface VKPlaceholderTextView : UITextView

@property(nonatomic, strong) NSString *placeholder;
@property(nonatomic, strong) UIColor *placeholderColor;
@property(nonatomic, strong) UILabel *placeholderLabel;

- (void)textChanged:(NSNotification *)notification;

@end

@implementation VKPlaceholderTextView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }

    if (!self.placeholderColor) {
        [self setPlaceholderColor:[UIColor lightGrayColor]];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification {
    if (notification.object != self) return;
    if (!self.placeholder.length) {
        return;
    }
    if (!self.text.length) {
        [_placeholderLabel setHidden:NO];
    } else {
        [_placeholderLabel setHidden:YES];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if (!self.text.length) {
        [_placeholderLabel setHidden:NO];
    } else {
        [_placeholderLabel setHidden:YES];
    }
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    if (placeholder.length) {
        if (_placeholderLabel == nil) {
            UIEdgeInsets inset = self.contentInset;
            if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                inset = self.textContainerInset;
            }
            _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset.left + 4, inset.top, self.bounds.size.width - inset.left - inset.right, 0)];
            _placeholderLabel.font = self.font;
            _placeholderLabel.hidden = YES;
            _placeholderLabel.textColor = self.placeholderColor;
            _placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeholderLabel.numberOfLines = 0;
            _placeholderLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:_placeholderLabel];
        }

        _placeholderLabel.text = placeholder;
        [_placeholderLabel sizeToFit];
        [self sendSubviewToBack:_placeholderLabel];
    }

    if (self.text.length == 0 && placeholder.length) {
        [_placeholderLabel setHidden:NO];
    }
}

/**
* iOS 7 text view measurement.
* Author: tarmes;
* Source: http://stackoverflow.com/a/19047464/1271424
*/
- (CGFloat)measureHeightOfUITextView {
    UITextView *textView = self;
    if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGRect frame = textView.bounds;

        // Take account of the padding added around the text.

        UIEdgeInsets textContainerInsets = textView.textContainerInset;
        UIEdgeInsets contentInsets = textView.contentInset;

        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;

        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;

        NSString *textToMeasure = textView.text.length ? textView.text : _placeholder;
        if ([textToMeasure hasSuffix:@"\n"]) {
            textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
        }

        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];

        NSDictionary *attributes = @{NSFontAttributeName : textView.font, NSParagraphStyleAttributeName : paragraphStyle};

        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];

        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return measuredHeight;
    }
    else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        if (self.text.length && textView.contentSize.height > 0) {
            return MAX(textView.contentSize.height + self.contentInset.top + self.contentInset.bottom, 36.0f);
        }
        return [self.placeholder sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + self.contentInset.top + self.contentInset.bottom;
#endif
    }
    return 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (VK_SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        CGSize size = self.contentSize;
        size.width = size.width - self.contentInset.left - self.contentInset.right;
        [self setContentSize:size];
    }

}
@end

///----------------------------
/// @name Special kind of button for privacy settings
///----------------------------

@interface VKPrivacyButton : UIButton
@end

@implementation VKPrivacyButton
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    CGFloat separatorHeight = 1 / [UIScreen mainScreen].scale;
    UIView *topSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, separatorHeight)];
    topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [topSeparatorView setBackgroundColor:[VKUtil colorWithRGB:0xc8cacc]];
    [self addSubview:topSeparatorView];
    [self setImage:VKImageNamed(@"Disclosure") forState:UIControlStateNormal];
    [self setBackgroundColor:[VKUtil colorWithRGB:0xfafbfc]];
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    if (highlighted) {
        self.backgroundColor = [VKUtil colorWithRGB:0xd9d9d9];
    }
    else {
        self.backgroundColor = [VKUtil colorWithRGB:0xfafbfc];
    }
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect frame = [super imageRectForContentRect:contentRect];
    frame.origin.x = CGRectGetMaxX(contentRect) - CGRectGetWidth(frame) - self.imageEdgeInsets.right + self.imageEdgeInsets.left;
    return frame;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect frame = [super titleRectForContentRect:contentRect];
    frame.origin.x = CGRectGetMinX(frame) - CGRectGetWidth([self imageRectForContentRect:contentRect]);
    return frame;
}
@end

@interface VKLinkAttachView : UIView
@property(nonatomic, strong) UILabel *linkTitle;
@property(nonatomic, strong) UILabel *linkHost;
@property(nonatomic, strong) VKShareLink *targetLink;
@end

@implementation VKLinkAttachView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    _linkTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 21)];
    _linkTitle.font = [UIFont systemFontOfSize:16];
    _linkTitle.textColor = [VKUtil colorWithRGB:0x4978ad];
    _linkTitle.backgroundColor = [UIColor clearColor];
    _linkTitle.numberOfLines = 1;
    [self addSubview:_linkTitle];

    _linkHost = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 21)];
    _linkHost.font = [UIFont systemFontOfSize:16];
    _linkHost.textColor = [VKUtil colorWithRGB:0x999999];
    _linkHost.backgroundColor = [UIColor clearColor];
    _linkHost.numberOfLines = 1;
    [self addSubview:_linkHost];

    self.backgroundColor = [UIColor clearColor];

    return self;
}

- (void)sizeToFit {
    [_linkTitle sizeToFit];
    _linkTitle.frame = CGRectMake(0, 0, self.frame.size.width, _linkHost.frame.size.height);
    [_linkHost sizeToFit];
    _linkHost.frame = CGRectMake(0, CGRectGetMaxY(_linkTitle.frame) + 2, self.frame.size.width, _linkHost.frame.size.height);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(_linkHost.frame));
}

- (void)setTargetLink:(VKShareLink *)targetLink {
    _targetLink = targetLink;
    _linkTitle.text = [targetLink.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _linkHost.text = [targetLink.link.host stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self sizeToFit];
}
@end

///-------------------------------
/// @name View for internal share dialog controller
///-------------------------------
static const CGFloat kAttachmentsViewSize = 100.0f;

@interface VKShareDialogView : UIView <UITextViewDelegate>
@property(nonatomic, strong) UIView *notAuthorizedView;
@property(nonatomic, strong) UILabel *notAuthorizedLabel;
@property(nonatomic, strong) UIButton *notAuthorizedButton;
@property(nonatomic, strong) UIScrollView *contentScrollView;
@property(nonatomic, strong) UIButton *privacyButton;
@property(nonatomic, strong) UICollectionView *attachmentsCollection;
@property(nonatomic, strong) VKPlaceholderTextView *textView;
@property(nonatomic, strong) VKLinkAttachView *linkAttachView;
@end

@implementation VKShareDialogView {
    CGFloat lastTextViewHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [VKUtil colorWithRGB:0xfafbfc];
    {
        //View for authorizing, adds only when user is not authorized
        _notAuthorizedView = [[UIView alloc] initWithFrame:self.bounds];
        _notAuthorizedView.backgroundColor = [UIColor clearColor];
        _notAuthorizedView.backgroundColor = [VKUtil colorWithRGB:0xf2f2f5];
        _notAuthorizedView.autoresizingMask = UIViewAutoresizingNone;
        _notAuthorizedView.autoresizesSubviews = NO;

        _notAuthorizedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(_notAuthorizedView.frame) - 20, 0)];
        _notAuthorizedLabel.text = VKLocalizedString(@"UserNotAuthorized");
        _notAuthorizedLabel.font = [UIFont systemFontOfSize:15];
        _notAuthorizedLabel.textColor = [VKUtil colorWithRGB:0x737980];
        _notAuthorizedLabel.textAlignment = NSTextAlignmentCenter;
        _notAuthorizedLabel.numberOfLines = 0;
        _notAuthorizedLabel.backgroundColor = [UIColor clearColor];
        [_notAuthorizedView addSubview:_notAuthorizedLabel];

        _notAuthorizedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 34)];
        [_notAuthorizedButton setTitle:VKLocalizedString(@"Enter") forState:UIControlStateNormal];
        [_notAuthorizedButton setContentEdgeInsets:UIEdgeInsetsMake(4, 15, 4, 15)];
        _notAuthorizedButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_notAuthorizedView addSubview:_notAuthorizedButton];

        UIImage *buttonBg = VKImageNamed(@"BlueBtn");
        buttonBg = [buttonBg stretchableImageWithLeftCapWidth:floor(buttonBg.size.width / 2) topCapHeight:floorf(buttonBg.size.height / 2)];
        [_notAuthorizedButton setBackgroundImage:buttonBg forState:UIControlStateNormal];

        buttonBg = VKImageNamed(@"BlueBtn_pressed");
        buttonBg = [buttonBg stretchableImageWithLeftCapWidth:floor(buttonBg.size.width / 2) topCapHeight:floorf(buttonBg.size.height / 2)];
        [_notAuthorizedButton setBackgroundImage:buttonBg forState:UIControlStateHighlighted];

    }

    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _contentScrollView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    _contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _contentScrollView.scrollIndicatorInsets = _contentScrollView.contentInset;
    [self addSubview:_contentScrollView];

    _privacyButton = [[VKPrivacyButton alloc] initWithFrame:CGRectMake(0, frame.size.height - 44, frame.size.width, 44)];
    _privacyButton.titleLabel.font = [UIFont systemFontOfSize:16];
    _privacyButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _privacyButton.contentEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 14);
    _privacyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_privacyButton setTitle:VKLocalizedString(@"PostSettings") forState:UIControlStateNormal];
    [_privacyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:_privacyButton];

    _textView = [[VKPlaceholderTextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 36)];

    _textView.backgroundColor = [UIColor clearColor];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _textView.textContainerInset = UIEdgeInsetsMake(12, 10, 12, 10);
        _textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;

    } else {
        _textView.frame = CGRectMake(0, 0, frame.size.width - 20, 36);
        _textView.contentInset = UIEdgeInsetsMake(12, 10, 12, 0);
    }
    _textView.font = [UIFont systemFontOfSize:16.0f];
    _textView.delegate = self;
    _textView.textAlignment = NSTextAlignmentLeft;
    _textView.returnKeyType = UIReturnKeyDone;
    _textView.placeholder = VKLocalizedString(@"NewMessageText");
    [_contentScrollView addSubview:_textView];

    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 12;

    _attachmentsCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kAttachmentsViewSize) collectionViewLayout:layout];
    _attachmentsCollection.contentInset = UIEdgeInsetsMake(0, 16, 0, 16);
    _attachmentsCollection.backgroundColor = [UIColor clearColor];
    _attachmentsCollection.showsHorizontalScrollIndicator = NO;
    [_attachmentsCollection registerClass:[VKPhotoAttachmentCell class] forCellWithReuseIdentifier:@"VKPhotoAttachmentCell"];
    [_contentScrollView addSubview:_attachmentsCollection];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (_notAuthorizedView.superview) {
        _notAuthorizedView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        CGSize notAuthorizedTextBoundingSize = CGSizeMake(CGRectGetWidth(_notAuthorizedView.frame) - 20, CGFLOAT_MAX);
        CGSize notAuthorizedTextSize;
        if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            paragraphStyle.alignment = NSTextAlignmentLeft;

            NSDictionary *attributes = @{NSFontAttributeName : _notAuthorizedLabel.font,
                    NSParagraphStyleAttributeName : paragraphStyle};

            notAuthorizedTextSize = [_notAuthorizedLabel.text boundingRectWithSize:notAuthorizedTextBoundingSize
                                                                           options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                                        attributes:attributes
                                                                           context:nil].size;
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            notAuthorizedTextSize = [_notAuthorizedLabel.text sizeWithFont:_notAuthorizedLabel.font
                                                         constrainedToSize:notAuthorizedTextBoundingSize
                                                             lineBreakMode:NSLineBreakByWordWrapping];
#endif
        }

        [_notAuthorizedButton sizeToFit];

        _notAuthorizedLabel.frame = CGRectMake(10, roundf((CGRectGetHeight(_notAuthorizedView.frame) - notAuthorizedTextSize.height - CGRectGetHeight(_notAuthorizedButton.frame)) / 2), notAuthorizedTextBoundingSize.width, roundf(notAuthorizedTextSize.height));

        _notAuthorizedButton.frame = CGRectMake(roundf(_notAuthorizedLabel.center.x) - roundf(CGRectGetWidth(_notAuthorizedButton.frame) / 2),
                CGRectGetMaxY(_notAuthorizedLabel.frame) + roundf(CGRectGetHeight(_notAuthorizedButton.frame) / 2),
                CGRectGetWidth(_notAuthorizedButton.frame), CGRectGetHeight(_notAuthorizedButton.frame));
    }
    //Workaround for iOS 6 - ignoring contentInset.right
    _textView.frame = CGRectMake(0, 0, self.frame.size.width - (VK_SYSTEM_VERSION_LESS_THAN(@"7.0") ? 20 : 0), [_textView measureHeightOfUITextView]);
    [self positionSubviews];
}

- (void)positionSubviews {
    lastTextViewHeight = _textView.frame.size.height;
    _attachmentsCollection.frame = CGRectMake(0, lastTextViewHeight, self.frame.size.width, [_attachmentsCollection numberOfItemsInSection:0] ? kAttachmentsViewSize : 0);
    if (_linkAttachView) {
        _linkAttachView.frame = CGRectMake(14, CGRectGetMaxY(_attachmentsCollection.frame) + 5, self.frame.size.width - 20, 0);
        [_linkAttachView sizeToFit];
    }

    _contentScrollView.contentSize = CGSizeMake(self.frame.size.width, _linkAttachView ? CGRectGetMaxY(_linkAttachView.frame) : CGRectGetMaxY(_attachmentsCollection.frame));
}

- (void)textViewDidChange:(UITextView *)textView {
    CGFloat newHeight = [_textView measureHeightOfUITextView];
    if (fabs(newHeight - lastTextViewHeight) > 1) {
        textView.frame = CGRectMake(0, 0, self.frame.size.width - (VK_SYSTEM_VERSION_LESS_THAN(@"7.0") ? 20 : 0), newHeight);
        [textView layoutIfNeeded];
        [UIView animateWithDuration:0.2 animations:^{
            [self positionSubviews];
        }];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView endEditing:YES];
    }
    return YES;
}

- (void)setShareLink:(VKShareLink *)link {
    _linkAttachView = [[VKLinkAttachView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
    _linkAttachView.targetLink = link;
    [_contentScrollView addSubview:_linkAttachView];
    [self setNeedsLayout];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
@end

///-------------------------------
/// @name Internal view controller, root for share dialog navigation controller
///-------------------------------
@interface VKShareDialogControllerInternal ()
@property(nonatomic, readonly) UICollectionView *attachmentsScrollView;
@property(nonatomic, strong) UIBarButtonItem *sendButton;
@property(nonatomic, strong) NSMutableArray *attachmentsArray;
@property(nonatomic, strong) id targetOwner;
@property(nonatomic, strong) VKPostSettings *postSettings;
@property(nonatomic, assign) BOOL prepared;
@property(nonatomic, strong) id <VKSdkDelegate> originalSdkDelegate;

@end

@implementation VKShareDialogControllerInternal {
    dispatch_queue_t imageProcessingQueue;
}
- (instancetype)init {
    self = [super init];
    if (VK_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    imageProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    return self;
}

- (void)loadView {
    VKShareDialogView *view = [[VKShareDialogView alloc] initWithFrame:CGRectMake(0, 0, ipadWidth, ipadHeight)];
    view.attachmentsCollection.delegate = self;
    view.attachmentsCollection.dataSource = self;
    [view.notAuthorizedButton addTarget:self action:@selector(authorize:) forControlEvents:UIControlEventTouchUpInside];
    [view.privacyButton addTarget:self action:@selector(openSettings:) forControlEvents:UIControlEventTouchUpInside];

    self.view = view;
}

- (UICollectionView *)attachmentsScrollView {
    VKShareDialogView *view = (VKShareDialogView *) self.view;
    return view.attachmentsCollection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [VKBundle vkLibraryImageNamed:@"ic_vk_logo_nb"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:VKLocalizedString(@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
    _originalSdkDelegate = [VKSdk instance].delegate;
    [VKSdk instance].delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.prepared) return;
    VKShareDialogView *view = (VKShareDialogView *) self.view;
    if ([VKSdk wakeUpSession:self.parent.requestedScope]) {
        [view.notAuthorizedView removeFromSuperview];
        view.textView.text = _parent.text;
        [self prepare];
    } else {
        [self setNotAuthorized];
    }
}
- (void) setNotAuthorized {
    VKShareDialogView *view = (VKShareDialogView *) self.view;
    [view addSubview:view.notAuthorizedView];
    if ([VKSdk wakeUpSession]) {
        view.notAuthorizedLabel.text = VKLocalizedString(@"UserHasNoRequiredPermissions");
    }
    [view layoutSubviews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillAppear:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [VKSdk instance].delegate = _originalSdkDelegate;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepare {

    _postSettings = [VKPostSettings new];
    [self createAttachments];
    [[[VKApi users] get:@{VK_API_FIELDS : @"first_name_acc,can_post,sex,exports"}] executeWithResultBlock:^(VKResponse *response) {
        VKUser *user = [response.parsedModel firstObject];
        //Set this flags as @0 to show in the interface
        _postSettings.friendsOnly = @0;
        if (user.exports.twitter) {
            _postSettings.exportTwitter = @0;
        }
        if (user.exports.facebook) {
            _postSettings.exportFacebook = @0;
        }
        if (user.exports.livejournal) {
            _postSettings.exportLivejournal = @0;
        }
    }                                                                                          errorBlock:nil];
    self.prepared = YES;

}

- (NSArray *)rightBarButtonItems {
    if (!_sendButton) {
        _sendButton = [[UIBarButtonItem alloc] initWithTitle:VKLocalizedString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(sendMessage:)];
    }
    return @[_sendButton];
}

- (void)close:(id)sender {
    if (_parent.completionHandler != NULL) {
        _parent.completionHandler(VKShareDialogControllerResultCancelled);
    }
    if (_parent.dismissAutomatically) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)sendMessage:(id)sender {
    UITextView *textView = ((VKShareDialogView *) self.view).textView;
    textView.editable = NO;
    [textView endEditing:YES];
    self.navigationItem.rightBarButtonItems = nil;
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
    [activity startAnimating];

    NSMutableArray *attachStrings = [NSMutableArray arrayWithCapacity:_attachmentsArray.count];
    for (VKUploadingAttachment *attach in _attachmentsArray) {
        if (!attach.attachmentString) {
            [self performSelector:@selector(sendMessage:) withObject:sender afterDelay:1.0f];
            return;
        }
        [attachStrings addObject:attach.attachmentString];
    }
    if (_parent.shareLink) {
        [attachStrings addObject:[_parent.shareLink.link absoluteString]];
    }

    VKRequest *post = [[VKApi wall] post:@{VK_API_MESSAGE : textView.text ?: @"",
            VK_API_ATTACHMENTS : [attachStrings componentsJoinedByString:@","]}];
    NSMutableArray *exports = [NSMutableArray new];
    if (_postSettings.friendsOnly.boolValue) [post addExtraParameters:@{VK_API_FRIENDS_ONLY : @1}];
    if (_postSettings.exportTwitter.boolValue) [exports addObject:@"twitter"];
    if (_postSettings.exportFacebook.boolValue) [exports addObject:@"facebook"];
    if (_postSettings.exportLivejournal.boolValue) [exports addObject:@"livejournal"];
    if (exports.count) [post addExtraParameters:@{VK_API_SERVICES : [exports componentsJoinedByString:@","]}];

    [post executeWithResultBlock:^(VKResponse *response) {
        if (_parent.completionHandler != NULL) {
            _parent.completionHandler(VKShareDialogControllerResultDone);
        }
        if (_parent.dismissAutomatically) {
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }                 errorBlock:^(NSError *error) {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = [self rightBarButtonItems];
        textView.editable = YES;
        [textView becomeFirstResponder];
        [[[UIAlertView alloc] initWithTitle:nil message:VKLocalizedString(@"ErrorWhilePosting") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)openSettings:(id)sender {
    VKShareSettingsController *vc = [[VKShareSettingsController alloc] initWithPostSettings:self.postSettings];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)authorize:(id)sender {
    [VKSdk instance].delegate = self;
    [VKSdk authorize:_parent.requestedScope revokeAccess:YES forceOAuth:NO inApp:[VKSdk vkAppMayExists] ? NO : _parent.authorizeInApp];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *captcha = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [self.navigationController presentViewController:captcha animated:YES completion:nil];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    [self setNotAuthorized];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *) controller;
        UIViewController *target = nav.viewControllers[0];
        nav.viewControllers = @[];
        [self.navigationController pushViewController:target animated:YES];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {

}

#pragma mark -Attachments

- (void)createAttachments {
    self.navigationItem.rightBarButtonItems = [self rightBarButtonItems];

    CGFloat maxHeight = kAttachmentsViewSize;
    self.attachmentsArray = [NSMutableArray new];
    VKShareDialogView *shareDialogView = (VKShareDialogView *) self.view;
    //Attach and upload images
    for (VKUploadImage *img in _parent.uploadImages) {
        if (!(img.imageData || img.sourceImage)) continue;
        CGSize size = img.sourceImage.size;
        size = CGSizeMake(MAX(floor(size.width * maxHeight / size.height), 50), maxHeight);
        VKUploadingAttachment *attach = [VKUploadingAttachment new];
        attach.isUploaded = NO;
        attach.attachSize = size;
        attach.targetUpload = img;
        attach.preview = [img.sourceImage vkRoundCornersImage:0.0f resultSize:size];
        [self.attachmentsArray addObject:attach];

        VKRequest *uploadRequest = [VKApi uploadWallPhotoRequest:img.sourceImage parameters:img.parameters userId:0 groupId:0];

        [uploadRequest setCompleteBlock:^(VKResponse *res) {
            VKPhoto *photo = [res.parsedModel firstObject];
            attach.isUploaded = YES;
            attach.attachmentString = photo.attachmentString;
            attach.uploadingRequest = nil;
            [self.attachmentsScrollView reloadData];
        }];
        [uploadRequest setErrorBlock:^(NSError *error) {
            NSLog(@"Error: %@", error.vkError);
            [self removeAttachIfExists:attach];
            attach.uploadingRequest = nil;
            [self.attachmentsScrollView reloadData];
            [shareDialogView setNeedsLayout];
        }];
        [uploadRequest start];
        attach.uploadingRequest = uploadRequest;
    }

    if (_parent.vkImages.count) {
        NSMutableDictionary *attachById = [NSMutableDictionary new];
        for (NSString *photo in _parent.vkImages) {
            NSAssert([photo isKindOfClass:[NSString class]], @"vkImages must contains only string photo ids");
            if (attachById[photo]) continue;
            VKUploadingAttachment *attach = [VKUploadingAttachment new];
            attach.attachSize = CGSizeMake(kAttachmentsViewSize, kAttachmentsViewSize);
            attach.attachmentString = [@"photo" stringByAppendingString:photo];
            attach.isDownloading = YES;
            [self.attachmentsArray addObject:attach];
            attachById[photo] = attach;
        }

        VKRequest *req = [VKRequest requestWithMethod:@"photos.getById" andParameters:@{@"photos" : [_parent.vkImages componentsJoinedByString:@","], @"photo_sizes" : @1} andHttpMethod:@"GET" classOfModel:[VKPhotoArray class]];
        [req setCompleteBlock:^(VKResponse *res) {
            VKPhotoArray *photos = res.parsedModel;
            NSArray *requiredSizes = @[@"p", @"q", @"m"];
            for (VKPhoto *photo in photos) {
                NSString *photoSrc = nil;
                for (NSString *type in requiredSizes) {
                    photoSrc = [photo.sizes photoSizeWithType:type].src;
                    if (photoSrc) break;
                }
                if (!photoSrc) {
                    continue;
                }

                NSString *photoId = [NSString stringWithFormat:@"%@_%@", photo.owner_id, photo.id];
                VKUploadingAttachment *attach = attachById[photoId];

                [attachById removeObjectForKey:photoId];

                VKHTTPOperation *imageLoad = [[VKHTTPOperation alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:photoSrc]]];
                [imageLoad setCompletionBlockWithSuccess:^(VKHTTPOperation *operation, id responseObject) {
                    UIImage *result = [UIImage imageWithData:operation.responseData];
                    result = [result vkRoundCornersImage:0 resultSize:CGSizeMake(kAttachmentsViewSize, kAttachmentsViewSize)];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        attach.preview = result;
                        attach.isDownloading = NO;
                        NSInteger index = [self.attachmentsArray indexOfObject:attach];
                        [self.attachmentsScrollView performBatchUpdates:^{
                            [self.attachmentsScrollView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
                        }                                    completion:nil];

                    });

                }                                failure:^(VKHTTPOperation *operation, NSError *error) {
                    [self removeAttachIfExists:attach];
                    [self.attachmentsScrollView reloadData];
                }];
                imageLoad.successCallbackQueue = imageProcessingQueue;
                [[VKHTTPClient getClient] enqueueOperation:imageLoad];
            }
            [self.attachmentsScrollView performBatchUpdates:^{
                for (VKUploadingAttachment *attach in attachById.allValues) {
                    NSInteger index = [self.attachmentsArray indexOfObject:attach];
                    if (index != NSNotFound) {
                        [self.attachmentsArray removeObjectAtIndex:index];
                        [self.attachmentsScrollView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
                    }
                }
            }                                    completion:nil];
            [self.attachmentsScrollView reloadData];
        }];
        [req start];
    }
    [self.attachmentsScrollView reloadData];

    if (_parent.shareLink) {
        [shareDialogView setShareLink:_parent.shareLink];
    }
}

#pragma mark - UICollectionView work

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.attachmentsArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    VKUploadingAttachment *object = self.attachmentsArray[indexPath.item];
    return object.attachSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VKUploadingAttachment *attach = self.attachmentsArray[indexPath.item];
    VKPhotoAttachmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VKPhotoAttachmentCell" forIndexPath:indexPath];

    cell.attachImageView.image = attach.preview;
    VKRequest *request = attach.uploadingRequest;

    __weak VKPhotoAttachmentCell *weakCell = cell;
    [request setProgressBlock:^(VKProgressType progressType, long long bytesLoaded, long long bytesTotal) {
        if (bytesTotal < 0) {
            return;
        }
        weakCell.progress = bytesLoaded * 1.0f / bytesTotal;
    }];
    if (attach.isDownloading) {
        cell.progress = -1;
    }
    if (!attach.isDownloading && !request) {
        [cell hideProgress];
    }

    return cell;
}

- (void)removeAttachIfExists:(VKUploadingAttachment *)attach {
    NSInteger index = [self.attachmentsArray indexOfObject:attach];
    if (index != NSNotFound) {
        [self.attachmentsArray removeObjectAtIndex:index];
        [self.attachmentsScrollView reloadData];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    _sendButton.enabled = YES;
    if (!textView.text.length && !self.attachmentsArray.count) {
        _sendButton.enabled = NO;
    }
}
@end

static NSString *const SETTINGS_FRIENDS_ONLY = @"FriendsOnly";
static NSString *const SETTINGS_TWITTER = @"ExportTwitter";
static NSString *const SETTINGS_FACEBOOK = @"ExportFacebook";
static NSString *const SETTINGS_LIVEJOURNAL = @"ExportLivejournal";

@interface VKShareSettingsController ()
@property(nonatomic, strong) NSArray *rows;
@end

@implementation VKShareSettingsController

- (instancetype)initWithPostSettings:(VKPostSettings *)settings {
    self = [super init];
    self.currentSettings = settings;
    NSMutableArray *newRows = [NSMutableArray new];
    if (_currentSettings.friendsOnly)
        [newRows addObject:SETTINGS_FRIENDS_ONLY];
    if (_currentSettings.exportTwitter)
        [newRows addObject:SETTINGS_TWITTER];
    if (_currentSettings.exportFacebook)
        [newRows addObject:SETTINGS_FACEBOOK];
    if (_currentSettings.exportLivejournal)
        [newRows addObject:SETTINGS_LIVEJOURNAL];
    self.rows = newRows;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    UISwitch *switchView;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchView.tintColor = VK_COLOR;
        switchView.onTintColor = VK_COLOR;

        cell.accessoryView = switchView;

        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    } else {
        switchView = (UISwitch *) cell.accessoryView;
    }
    NSString *currentRow = self.rows[indexPath.row];
    if ([currentRow isEqual:SETTINGS_FRIENDS_ONLY]) {
        switchView.on = self.currentSettings.friendsOnly.boolValue;
    } else {
        if ([currentRow isEqual:SETTINGS_TWITTER]) {
            switchView.on = self.currentSettings.exportTwitter.boolValue;
        } else if ([currentRow isEqual:SETTINGS_FACEBOOK]) {
            switchView.on = self.currentSettings.exportFacebook.boolValue;
        } else if ([currentRow isEqual:SETTINGS_LIVEJOURNAL]) {
            switchView.on = self.currentSettings.exportLivejournal.boolValue;
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

- (void)switchChanged:(UISwitch *)sender {
    NSString *currentRow = self.rows[sender.tag - 100];
    if ([currentRow isEqual:SETTINGS_FRIENDS_ONLY]) {
        self.currentSettings.friendsOnly = @(sender.on);
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    } else if ([currentRow isEqual:SETTINGS_TWITTER]) {
        self.currentSettings.exportTwitter = @(sender.on);
    } else if ([currentRow isEqual:SETTINGS_FACEBOOK]) {
        self.currentSettings.exportFacebook = @(sender.on);
    } else if ([currentRow isEqual:SETTINGS_LIVEJOURNAL]) {
        self.currentSettings.exportLivejournal = @(sender.on);
    }
}

@end


@implementation VKShareLink

- (instancetype)initWithTitle:(NSString *)title link:(NSURL *)link {
    self = [super init];
    self.title = title ?: VKLocalizedString(@"Link");
    self.link = link;
    return self;
}

@end


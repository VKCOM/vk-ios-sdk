//
//  VKApiConst.h
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

typedef NSString* VKDisplayType;
static VKDisplayType const VK_DISPLAY_IOS          = @"ios";
static VKDisplayType const VK_DISPLAY_MOBILE       = @"mobile";
//Commons
static NSString *const VK_API_USER_ID              = @"user_id";
static NSString *const VK_API_USER_IDS             = @"user_ids";
static NSString *const VK_API_FIELDS               = @"fields";
static NSString *const VK_API_SORT                 = @"sort";
static NSString *const VK_API_OFFSET               = @"offset";
static NSString *const VK_API_COUNT                = @"count";
static NSString *const VK_API_OWNER_ID             = @"owner_id";

//auth
static NSString *const VK_API_LANG                 = @"lang";
static NSString *const VK_API_ACCESS_TOKEN         = @"access_token";
static NSString *const VK_API_SIG                  = @"sig";

//get users
static NSString *const VK_API_NAME_CASE            = @"name_case";
static NSString *const VK_API_ORDER                = @"order";

//Get subscriptions
static NSString *const VK_API_EXTENDED             = @"extended";

//Search
static NSString *const VK_API_Q                    = @"q";
static NSString *const VK_API_CITY                 = @"city";
static NSString *const VK_API_COUNTRY              = @"country";
static NSString *const VK_API_HOMETOWN             = @"hometown";
static NSString *const VK_API_UNIVERSITY_COUNTRY   = @"university_country";
static NSString *const VK_API_UNIVERSITY           = @"university";
static NSString *const VK_API_UNIVERSITY_YEAR      = @"university_year";
static NSString *const VK_API_SEX                  = @"sex";
static NSString *const VK_API_STATUS               = @"status";
static NSString *const VK_API_AGE_FROM             = @"age_from";
static NSString *const VK_API_AGE_TO               = @"age_to";
static NSString *const VK_API_BIRTH_DAY            = @"birth_day";
static NSString *const VK_API_BIRTH_MONTH          = @"birth_month";
static NSString *const VK_API_BIRTH_YEAR           = @"birth_year";
static NSString *const VK_API_ONLINE               = @"online";
static NSString *const VK_API_HAS_PHOTO            = @"has_photo";
static NSString *const VK_API_SCHOOL_COUNTRY       = @"school_country";
static NSString *const VK_API_SCHOOL_CITY          = @"school_city";
static NSString *const VK_API_SCHOOL               = @"school";
static NSString *const VK_API_SCHOOL_YEAR          = @"school_year";
static NSString *const VK_API_RELIGION             = @"religion";
static NSString *const VK_API_INTERESTS            = @"interests";
static NSString *const VK_API_COMPANY              = @"company";
static NSString *const VK_API_POSITION             = @"position";
static NSString *const VK_API_GROUP_ID             = @"group_id";

static NSString *const VK_API_FRIENDS_ONLY         = @"friends_only";
static NSString *const VK_API_FROM_GROUP           = @"from_group";
static NSString *const VK_API_MESSAGE              = @"message";
static NSString *const VK_API_ATTACHMENTS          = @"attachments";
static NSString *const VK_API_SERVICES             = @"services";
static NSString *const VK_API_SIGNED               = @"signed";
static NSString *const VK_API_PUBLISH_DATE         = @"publish_date";
static NSString *const VK_API_LAT                  = @"lat";
static NSString *const VK_API_LONG                 = @"long";
static NSString *const VK_API_PLACE_ID             = @"place_id";
static NSString *const VK_API_POST_ID              = @"post_id";

//Errors
static NSString *const VK_API_ERROR_CODE           = @"error_code";
static NSString *const VK_API_ERROR_MSG            = @"error_msg";
static NSString *const VK_API_REQUEST_PARAMS       = @"request_params";

//Captcha
static NSString *const VK_API_CAPTCHA_IMG          = @"captcha_img";
static NSString *const VK_API_CAPTCHA_SID          = @"captcha_sid";
static NSString *const VK_API_CAPTCHA_KEY          = @"captcha_key";
static NSString *const VK_API_REDIRECT_URI         = @"redirect_uri";


//Photos
static NSString *const VK_API_PHOTO                = @"photo";
static NSString *const VK_API_ALBUM_ID             = @"album_id";


//Enums

typedef enum VKProgressType {
	VKProgressTypeUpload,
	VKProgressTypeDownload
} VKProgressType;

//Events
static NSString *const VKCaptchaAnsweredEvent      = @"VKCaptchaAnsweredEvent";

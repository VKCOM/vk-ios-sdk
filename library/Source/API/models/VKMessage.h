//
//  VKMessage.h
//
//  Copyright (c) 2016 VK.com
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

#import "VKApiObjectArray.h"
#import "VKAttachment.h"

@class VKMessage;
@class VKFWDMessage;
@class VKFWDMessagesArray;
@class VKPushSettings;
@class VKGeoPlace;

@interface VKFWDMessage : VKApiObject

@property (nonatomic) NSNumber *user_id;
@property (nonatomic) NSNumber *date;
@property (nonatomic) NSString *body;
@property (nonatomic) VKAttachments *attachments;
@property (nonatomic) VKFWDMessagesArray *fwd_messages;

@end

@interface VKFWDMessagesArray : VKApiObjectArray
@end

@interface VKPushSettings : VKApiObject

@property (nonatomic) NSNumber *sound;
@property (nonatomic) NSNumber *disabled_until;

@end

@interface VKMessage : VKApiObject

@property (nonatomic) NSNumber *id;
@property (nonatomic) NSNumber *user_id;
@property (nonatomic) NSNumber *from_id;
@property (nonatomic) NSNumber *date;
@property (nonatomic) NSNumber *read_state;
@property (nonatomic) NSNumber *out;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *body;
@property (nonatomic) NSNumber *random_id;

@property (nonatomic) VKGeoPlace *geo;
@property (nonatomic) VKAttachments *attachments;
@property (nonatomic) VKFWDMessagesArray *fwd_messages;

@property (nonatomic) NSNumber *important;
@property (nonatomic) NSNumber *deleted;

@property (nonatomic) NSNumber *chat_id;
@property (nonatomic) NSArray<NSNumber*> *chat_active;
@property (nonatomic) VKPushSettings *push_settings;
@property (nonatomic) NSNumber *users_count;
@property (nonatomic) NSNumber *admin_id;
@property (nonatomic) NSString *action;
@property (nonatomic) NSNumber *action_mid;
@property (nonatomic) NSNumber *action_email;
@property (nonatomic) NSString *action_text;
@property (nonatomic) NSNumber *emoji;

@property (nonatomic) NSString *photo_50;
@property (nonatomic) NSString *photo_100;
@property (nonatomic) NSString *photo_200;

@end

@interface VKMessagesArray : VKApiObjectArray
@end
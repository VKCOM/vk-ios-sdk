//
//  VKGroup.h
//  sdk
//
//  Created by Roman Truba on 16.07.14.
//  Copyright (c) 2014 VK. All rights reserved.
//

#import "VKApiObjectArray.h"
#import "VKUser.h"

@interface VKGeoPlace : VKApiObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *created;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSNumber *group_id;
@property (nonatomic, strong) NSNumber *group_photo;
@property (nonatomic, strong) NSNumber *checkins;
@property (nonatomic, strong) NSNumber *updated;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *country;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSNumber *showmap;
@end

@interface VKGroupContact : VKApiObject

@property (nonatomic, strong) NSNumber *user_id;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *email;

@end

@interface VKGroupContacts : VKApiObjectArray

@end

@interface VKGroupLink : VKApiObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *photo_50;
@property (nonatomic, strong) NSString *photo_100;

@end

@interface VKGroupLinks : VKApiObjectArray

@end

@interface VKGroup : VKApiObject
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screen_name;
/**
 * является ли сообщество закрытым. Возможные значения:
 * 0 — открытое;
 * 1 — закрытое;
 * 2 — частное.
 */
@property (nonatomic, strong) NSNumber *is_closed;
/**
 * тип сообщества:
 * group — группа;
 * page — публичная страница;
 * event — мероприятие.
 */
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSNumber *is_admin;
/**
 * полномочия текущего пользователя (если is_admin=1):
 * 1 — модератор;
 * 2 — редактор;
 * 3 — администратор.
 */
@property (nonatomic, strong) NSNumber *admin_level;
@property (nonatomic, strong) NSNumber *is_member;
@property (nonatomic, strong) VKCity   *city;
@property (nonatomic, strong) VKCountry *country;
@property (nonatomic, strong) VKGeoPlace *place;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *wiki_page;
@property (nonatomic, strong) NSNumber *members_count;
@property (nonatomic, strong) VKCounters *counters;
@property (nonatomic, strong) NSNumber *start_date;
@property (nonatomic, strong) NSNumber *end_date;
@property (nonatomic, strong) NSNumber *finish_date;
@property (nonatomic, strong) NSNumber *can_post;
@property (nonatomic, strong) NSNumber *can_see_all_posts;
@property (nonatomic, strong) NSNumber *can_create_topic;
@property (nonatomic, strong) NSNumber *can_upload_doc;
@property (nonatomic, strong) NSString *activity;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) VKAudio  *status_audio;
@property (nonatomic, strong) VKGroupContacts *contacts;
@property (nonatomic, strong) VKGroupLinks *links;
@property (nonatomic, strong) NSNumber *fixed_post;
@property (nonatomic, strong) NSNumber *verified;
@property (nonatomic, strong) NSString *site;
@property (nonatomic, strong) NSString *photo_50;
@property (nonatomic, strong) NSString *photo_100;
@property (nonatomic, strong) NSString *photo_200;
@property (nonatomic, strong) NSString *photo_max_orig;
@property (nonatomic, strong) NSNumber *is_request;
@property (nonatomic, strong) NSNumber *is_invite;
@property (nonatomic, strong) VKPhotoArray *photos;
@property (nonatomic, strong) NSNumber *photos_count;
@property (nonatomic, strong) NSNumber *invited_by;
@property (nonatomic, assign) NSInteger invite_state;
@property (nonatomic, strong) NSString *deactivated;
@property (nonatomic, strong) NSNumber *blacklisted;

@end

@interface VKGroups : VKApiObjectArray

@end
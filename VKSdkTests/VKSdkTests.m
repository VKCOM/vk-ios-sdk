//
//  VKSdkTests.m
//  VKSdkTests
//
//  Created by Roman Truba on 27.06.16.
//  Copyright © 2016 VK. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VKUser.h"
#import "VKUtil.h"
#import "VKSdk.h"

@interface VKSdkTests : XCTestCase

@end

@implementation VKSdkTests

- (void)setUp {
    [super setUp];
    
    self.continueAfterFailure = NO;
    
    [VKSdk initializeWithAppId:@"3974615" apiVersion:@"5.50"];
    
    NSURL *URL = [NSURL URLWithString:@"https://api.vk.com"];
    
    [NSURLRequest.class performSelector:NSSelectorFromString(@"setAllowsAnyHTTPSCertificate:forHost:")
                             withObject:NSNull.null  // Just need to pass non-nil here to appear as a BOOL YES, using the NSNull.null singleton is pretty safe
                             withObject:[URL host]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

static NSString *const ALL_USER_FIELDS = @"id,first_name,last_name,sex,bdate,city,country,photo_50,photo_100,photo_200_orig,photo_200,photo_400_orig,photo_max,photo_max_orig,online,online_mobile,lists,domain,has_mobile,contacts,connections,site,education,universities,schools,can_post,can_see_all_posts,can_see_audio,can_write_private_message,status,last_seen,relation,relatives,counters";

- (void)testApi {
    VKRequest *request = [VKRequest requestWithMethod:@"users.get" parameters:@{VK_API_USER_ID : @1, VK_API_FIELDS : ALL_USER_FIELDS} modelClass:[VKUsersArray class]];
    [request setPreferredLang:@"ru"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"Api call: %@", request.methodName]];
    
    [request executeWithResultBlock:^(VKResponse<VKUsersArray*> *response) {
        XCTAssertNotNil(response.parsedModel);
        XCTAssertTrue([response.parsedModel isKindOfClass:[VKUsersArray class]]);
        
        NSError *error = nil;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[response.responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        XCTAssertNil(error);
        [self validateUsers:response.parsedModel withJsonData:jsonObject];
        
        [expectation fulfill];
    } errorBlock:^(NSError *error) {
        XCTAssertNil(error);
    }];
    
    [self waitForExpectationsWithTimeout:5.f handler:^(NSError * _Nullable error) {
        NSLog(@"Request timed out %@", error);
    }];
}

- (void)testUserParse {
    NSString *PaulDurov = @"{\"response\":[{\"id\":1,\"first_name\":\"Павел\",\"last_name\":\"Дуров\",\"sex\":2,\"domain\":\"durov\",\"bdate\":\"10.10.1984\",\"city\":{\"id\":2,\"title\":\"Санкт-Петербург\"},\"country\":{\"id\":1,\"title\":\"Россия\"},\"photo_50\":\"https:\\/\\/pp.vk.me\\/c629231\\/v629231001\\/c543\\/FfB--bOEVOY.jpg\",\"photo_100\":\"https:\\/\\/pp.vk.me\\/c629231\\/v629231001\\/c542\\/fcMCbfjDsv0.jpg\",\"photo_200\":\"https:\\/\\/pp.vk.me\\/c629231\\/v629231001\\/c541\\/TaUV7CG7RHg.jpg\",\"photo_max\":\"https:\\/\\/pp.vk.me\\/c629231\\/v629231001\\/c541\\/TaUV7CG7RHg.jpg\",\"photo_200_orig\":\"https:\\/\\/pp.vk.me\\/c629231\\/v629231001\\/c535\\/Aolq7Qohi2o.jpg\",\"photo_400_orig\":\"https:\\/\\/pp.vk.me\\/c629231\\/v629231001\\/c536\\/dcqdvDEUs4E.jpg\",\"photo_max_orig\":\"https:\\/\\/pp.vk.me\\/c629231\\/v629231001\\/c536\\/dcqdvDEUs4E.jpg\",\"has_mobile\":1,\"online\":0,\"can_post\":0,\"can_see_all_posts\":0,\"can_see_audio\":0,\"can_write_private_message\":0,\"twitter\":\"durov\",\"instagram\":\"durov\",\"site\":\"http:\\/\\/telegram.org\",\"status\":\"道德經\",\"last_seen\":{\"time\":1398447188,\"platform\":7},\"common_count\":2,\"counters\":{\"albums\":2,\"videos\":14,\"audios\":0,\"notes\":6,\"photos\":226,\"friends\":721,\"online_friends\":126,\"mutual_friends\":2,\"followers\":6062370,\"subscriptions\":1,\"pages\":42},\"university\":1,\"university_name\":\"СПбГУ\",\"faculty\":0,\"faculty_name\":\"\",\"graduation\":2006,\"relation\":0,\"universities\":[{\"id\":1,\"country\":1,\"city\":2,\"name\":\"СПбГУ\",\"graduation\":2006}],\"schools\":[{\"id\":\"1035386\",\"country\":88,\"city\":16,\"name\":\"Sc.Elem. Coppino - Falletti di Barolo\",\"year_from\":1990,\"year_to\":1992,\"class\":\"\"},{\"id\":\"1\",\"country\":1,\"city\":2,\"name\":\"Академическая гимназия (АГ) СПбГУ\",\"year_from\":1996,\"year_to\":2001,\"year_graduated\":2001,\"class\":\"о\",\"type\":1,\"type_str\":\"Гимназия\"}],\"relatives\":[]}]}";
    
    NSError *error = nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[PaulDurov dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    XCTAssertNil(error);
    
    __block VKUsersArray *users  = [[VKUsersArray alloc] initWithDictionary:jsonObject];
    XCTAssert(users.count == 1);
    XCTAssert(users.items.count == 1);

    [self validateUsers:users withJsonData:jsonObject];
}

- (void)validateUsers:(VKUsersArray*)users withJsonData:(NSDictionary*)jsonData {
    
    VKUser *user = users.items.firstObject;
    
    NSArray *jsonResponse = VK_ENSURE_ARRAY(jsonData[@"response"]);
    XCTAssertNotNil(jsonResponse);
    NSDictionary *jsonUser = VK_ENSURE_DICT(jsonResponse.firstObject);
    
    for (NSString *key in jsonUser) {
        id userValue = [user valueForKey:key];
        XCTAssertNotNil(userValue);
        
        NSDictionary *dictValue = VK_ENSURE_DICT(jsonUser[key]);
        if (dictValue) {
            NSLog(@"%@ %@", key, [userValue class]);
            XCTAssert([userValue isKindOfClass:[VKApiObject class]] == YES);
        }
    }
    
    
    XCTAssertNotNil(user);
    XCTAssertEqualObjects(user.first_name, @"Павел");
    XCTAssertEqualObjects(user.last_name, @"Дуров");
    
    XCTAssertNotNil(VK_ENSURE(user.country, [VKCountry class]));
    XCTAssertEqualObjects(user.country.id, @(1));
    XCTAssertEqualObjects(user.country.title, @"Россия");
    
    // Universities
    XCTAssertNotNil(VK_ENSURE(user.universities, [VKUniversities class]));
    XCTAssertEqual(user.universities.count, 1);
    
    VKUniversity *university = user.universities.firstObject;
    XCTAssertNotNil(university);
    XCTAssertEqualObjects(university.name, @"СПбГУ");
    
    // Schools
    XCTAssertNotNil(VK_ENSURE(user.schools, [VKSchools class]));
    XCTAssertEqual(user.schools.count, 2);
    for (VKSchool *school in user.schools) {
        XCTAssertNotNil(VK_ENSURE(school, [VKSchool class]));
        XCTAssertNotNil(school.id);
        XCTAssertNotNil(school.name);
        XCTAssertNotNil(school.name);
    }
    
}

@end

//
//  GBDataProvider.m
//  KTVGrab
//
//  Created by Vic on 2022/3/11.
//

#import "GBDataProvider.h"

#import "GBTokenAPI.h"
#import "GBGetRoomListAPI.h"
#import "GBJoinRoomAPI.h"
#import "GBHeartbeatAPI.h"
#import "GBLeaveRoomAPI.h"
#import "GBCloseRoomAPI.h"
#import "GBBeginRoundAPI.h"
#import "GBGrabMicAPI.h"
#import "GBGetRandomSongsAPI.h"
#import "GBSongsReadyAPI.h"
#import "GBGetUserListAPI.h"
#import "GBUploadScoreAPI.h"
#import "GBGetRoomInfoAPI.h"
#import "GBOperateMicAPI.h"
#import "GBEnterNextRoundAPI.h"

@implementation GBDataProvider

+ (void)getTokenComplete:(void (^)(BOOL, NSError * _Nullable, NSDictionary *))complete {
  GBTokenAPI *api = [[GBTokenAPI alloc] init];
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    if (complete) {
      complete(YES, nil, data);
    }
  }];
}

+ (void)getRoomListWithCount:(NSUInteger)count beforeTime:(NSInteger)time complete:(void (^)(BOOL, NSError * _Nullable, NSArray<GBRoomRespModel *> * _Nonnull))complete {
  GBGetRoomListAPI *api = [[GBGetRoomListAPI alloc] init];
  api.pageCount = count;
  api.beginTimeStamp = time;
  
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    NSArray *models = [NSArray modelArrayWithClass:[GBRoomRespModel class] json:data[@"room_list"]];
    if (complete) {
      complete(YES, nil, models);
    }
  }];
}

+ (void)createRoomWithAPI:(GBCreateRoomAPI *)api complete:(void (^)(BOOL, NSError * _Nullable, GBRoomRespModel * _Nonnull))complete {
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    GBRoomRespModel *model = [GBRoomRespModel modelWithDictionary:data];
    if (complete) {
      complete(YES, nil, model);
    }
  }];
}

+ (void)joinRoomWithRoomID:(NSString *)roomID complete:(void (^)(BOOL, NSError * _Nullable, GBRoomRespModel * _Nonnull))complete {
  GBJoinRoomAPI *api = [[GBJoinRoomAPI alloc] init];
  api.roomID = roomID;
  
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    GBRoomRespModel *model = [GBRoomRespModel modelWithDictionary:data];
    if (complete) {
      complete(YES, nil, model);
    }
  }];
}

+ (void)getRoomInfoWithRoomID:(NSString *)roomID complete:(GBDataProviderRoomInfoCallback)complete {
  GBGetRoomInfoAPI *api = [[GBGetRoomInfoAPI alloc] init];
  api.roomID = roomID;
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    GBRoomRespModel *model = [GBRoomRespModel modelWithDictionary:data];
    if (complete) {
      complete(YES, nil, model);
    }
  }];
}

+ (void)heartbeatWithRoomID:(NSString *)roomID complete:(void (^)(BOOL, NSError * _Nullable, NSNumber * _Nonnull))complete {
  GBHeartbeatAPI *api = [[GBHeartbeatAPI alloc] init];
  api.roomID = roomID;
  
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    if (complete) {
      complete(YES, nil, data[@"interval"]);
    }
  }];
}

+ (void)internal_leaveRoomWithRoomID:(NSString *)roomID complete:(void (^)(BOOL, NSError * _Nullable, id _Nullable))complete {
  GBLeaveRoomAPI *api = [[GBLeaveRoomAPI alloc] init];
  api.roomID = roomID;
  
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    if (complete) {
      complete(YES, nil, nil);
    }
  }];
}

+ (void)leaveRoomWithRoomID:(NSString *)roomID complete:(void (^)(BOOL, NSError * _Nullable, id _Nullable))complete {
  [self internal_leaveRoomWithRoomID:roomID complete:^(BOOL suc, NSError * _Nullable err, id  _Nullable rsv) {
    //如果请求失败或者请求返回成功, 则透传 block
    if (!suc || !err) {
      !complete ?: complete(suc, err, rsv);
      return;
    }
    // 如果退房请求到达了服务器, 那么无论服务器返回什么错误, 退房都视为成功
    if (err) {
      !complete ?: complete(YES, nil, rsv);
    }
  }];
}

#pragma mark - 抢唱协议
+ (void)startRoundWithRoomID:(NSString *)roomID complete:(void (^)(BOOL, NSError * _Nullable, id _Nullable))complete {
  GBBeginRoundAPI *api = [[GBBeginRoundAPI alloc] init];
  api.roomID = roomID;
  
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    if (complete) {
      complete(YES, nil, nil);
    }
  }];
}

+ (void)grabMicWithRoomID:(NSString *)roomID round:(NSInteger)round index:(NSInteger)index complete:(GBDataProviderRsvCallback)complete {
  GBGrabMicAPI *api = [[GBGrabMicAPI alloc] init];
  api.roomID = roomID;
  api.round = round;
  api.index = index;
  
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    if (complete) {
      complete(YES, nil, nil);
    }
  }];
}

+ (void)getRandomSongsComplete:(void (^)(BOOL, NSError * _Nullable, NSArray<NSString *> * _Nonnull))complete {
  GBGetRandomSongsAPI *api = [[GBGetRandomSongsAPI alloc] init];
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    if (complete) {
      complete(YES, nil, data[@"song_id_list"]);
    }
  }];
}

+ (void)reportSongsReadyWithRoomID:(NSString *)roomID round:(NSUInteger)round invalidIDs:(NSArray<NSString *> *)invalidIDs complete:(void (^)(BOOL, NSError * _Nullable, id _Nullable))complete {
  GBSongsReadyAPI *api = [[GBSongsReadyAPI alloc] init];
  api.roomID = roomID;
  api.round = round;
  api.invalidUniqueIDs = invalidIDs;
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    if (complete) {
      complete(YES, nil, nil);
    }
  }];
}

+ (void)reportScore:(NSUInteger)score
         withRoomID:(NSString *)roomID
             songID:(NSString *)songID
           complete:(GBDataProviderRsvCallback)complete {
  GBUploadScoreAPI *api = [[GBUploadScoreAPI alloc] init];
  api.roomID = roomID;
  api.songID = songID;
  api.score = score;
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    if (complete) {
      complete(YES, nil, nil);
    }
  }];
}

+ (void)reportOperationWithMicEnabled:(BOOL)enable atIndex:(NSUInteger)index roomID:(NSString *)roomID complete:(GBDataProviderRsvCallback)complete {
  GBOperateMicAPI *api = [[GBOperateMicAPI alloc] init];
  api.roomID = roomID;
  api.micIndex = index;
  api.micState = enable ? 2 : 1;
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    if (complete) {
      complete(YES, nil, nil);
    }
  }];
}

+ (void)enterNextRoundWithRoomID:(NSString *)roomID complete:(GBDataProviderRsvCallback)complete {
  GBEnterNextRoundAPI *api = [[GBEnterNextRoundAPI alloc] init];
  api.roomID = roomID;
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    if (complete) {
      complete(YES, nil, nil);
    }
  }];
}

#pragma mark - 杂项
+ (void)getUserListWithRoomID:(NSString *)roomID complete:(void (^)(BOOL, NSError * _Nullable, NSArray<GBUserRespModel *> * _Nonnull))complete {
  GBGetUserListAPI *api = [[GBGetUserListAPI alloc] init];
  api.roomID = roomID;
  [api gb_startWithCompletionBlock:complete dataHandleBlock:^(NSDictionary * _Nullable data) {
    NSArray *respsModels = [NSArray modelArrayWithClass:[GBUserRespModel class] json:data[@"attendee_list"]];
    if (complete) {
      complete(YES, nil, respsModels);
    }
  }];
}

@end

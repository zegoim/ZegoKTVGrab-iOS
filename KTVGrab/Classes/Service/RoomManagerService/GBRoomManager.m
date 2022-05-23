//
//  GBRoomManager.m
//  KTVGrab
//
//  Created by Vic on 2022/3/11.
//

#import "GBRoomManager.h"
#import "GBDataProvider.h"
#import "GBIM.h"
#import "GBExpress.h"
#import "GBUser.h"
#import <Toast/Toast.h>
#import "GBzSDKLoader.h"

#define GB_ROOM_MANAGER_NOTIFY(x) [[NSNotificationCenter defaultCenter] postNotificationName:(x) object:nil];

@interface GBRoomManager ()

@property (nonatomic, strong, nullable) GBRoomInfo *roomInfo;
@property (nonatomic, strong, nullable) GBzSDKLoader *zSDKLoader;

@end

@implementation GBRoomManager

+ (instancetype)shared {
  static dispatch_once_t onceToken;
  static id _instance;
  dispatch_once(&onceToken, ^{
    _instance = [[self alloc] init];
  });
  return _instance;
}

- (GBzSDKLoader *)zSDKLoader {
  if (!_zSDKLoader) {
    _zSDKLoader = [[GBzSDKLoader alloc] init];
  }
  return _zSDKLoader;
}

- (void)enterRoomWithRoomInfo:(GBRoomInfo *)roomInfo complete:(void (^)(BOOL, NSError *, GBRunningRoomService *))complete {
  @weakify(self);
  [self loadZegoSDKsWithCompletion:^(NSError *error) {
    @strongify(self);
    if (error) {
      [self leaveRoomAndCleanUpSDK];
      complete(NO, error, nil);
      return;
    }
    self.roomInfo = roomInfo;
    
    [self realEnterRoomWithRoomInfo:roomInfo complete:^(BOOL suc, NSError * err, GBRunningRoomService *service) {
      if (err) {
        if (err.code == GBBackendErrorUserAlreadyInRoom) {
          [self leaveRoomAndCleanUpSDK];
        }else {
          [self.runningRoomService startBackendLeaveRoomProcess];
        }
      }
      complete(suc, err, service);
    }];
  }];
}

- (void)realEnterRoomWithRoomInfo:(GBRoomInfo *)roomInfo complete:(void (^)(BOOL, NSError * _Nonnull, GBRunningRoomService * _Nullable))complete {
  __block GBRunningRoomService *service = [[GBRunningRoomService alloc] initWithRoomInfo:roomInfo];
  self.runningRoomService = service;
  
  @weakify(self);
  void(^hookCompletion)(BOOL, NSError *, GBRoomInfo *) = ^(BOOL suc, NSError *err, GBRoomInfo *roomInfo) {
    @strongify(self);
    self.runningRoomService.roomInfo = roomInfo;
    if (complete) {
      complete(suc, err, service);
    }
  };
  
  if (roomInfo.roomID.length > 0) {
    [self joinRoomWithRoomInfo:roomInfo complete:hookCompletion];
  }else {
    [self createRoomWithRoomInfo:roomInfo complete:hookCompletion];
  }
}

- (void)leaveRoom {
  [self leaveMultipleRooms];
  self.roomInfo = nil;
}

//- (void)leaveRoomViaService:(GBRunningRoomService *)runningRoomService {
//  [runningRoomService startBackendLeaveRoomProcess];
//}

#pragma mark -
#pragma mark - Enter room

- (void)createRoomWithRoomInfo:(GBRoomInfo *)roomInfo complete:(void(^)(BOOL suc, NSError *err, GBRoomInfo *integratedRoomInfo))complete {
  
  GBCreateRoomAPI *api = [[GBCreateRoomAPI alloc] init];
  api.roomName = roomInfo.roomName;
  api.coverImage = roomInfo.imgURLString;
  api.rounds = roomInfo.rounds;
  api.songsPerRound = roomInfo.songsPerRound;
  api.maxMic = GB_CREATE_ROOM_MAX_SEAT_COUNT;
  
  // 创建后台房间
  @weakify(self);
  [GBDataProvider createRoomWithAPI:api complete:^(BOOL suc, NSError * _Nullable err, GBRoomRespModel * _Nonnull model) {
    @strongify(self);
    if (err) {
      if (complete) {
        complete(suc, err, roomInfo);
      }
      return;
    }
    // 更新 roomInfo
    [roomInfo updateWithRoomRespModel:model];
    
    [self enterSDKRoomWithRoomID:roomInfo.roomID roomName:roomInfo.roomName shouldCreate:YES complete:^(NSError *error) {
      complete(error == nil, error, roomInfo);
    }];
  }];
}

- (void)joinRoomWithRoomInfo:(GBRoomInfo *)roomInfo complete:(void(^)(BOOL suc, NSError *err, GBRoomInfo *integratedRoomInfo))complete {
  // 加入后台房间
  
  @weakify(self);
  [GBDataProvider joinRoomWithRoomID:roomInfo.roomID complete:^(BOOL suc, NSError * _Nullable err, GBRoomRespModel * _Nonnull model) {
    @strongify(self);
    if (err) {
      if (complete) {
        complete(suc, err, roomInfo);
      }
      return;
    }
    [roomInfo updateWithRoomRespModel:model];
    
    [self enterSDKRoomWithRoomID:roomInfo.roomID roomName:roomInfo.roomName shouldCreate:NO complete:^(NSError *error) {
      complete(error == nil, error, roomInfo);
    }];
  }];
}

- (void)enterSDKRoomWithRoomID:(NSString *)roomID roomName:(NSString *)roomName shouldCreate:(BOOL)shouldCreate complete:(GBErrorBlock)complete {
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    dispatch_group_t group = dispatch_group_create();
    __block NSError *err = nil;
    
    // 创建并加入IM房间
    dispatch_group_enter(group);
    
    if (shouldCreate) {
      [[GBIM shared] createRoomWithRoomID:roomID roomName:roomName complete:^(NSError *error) {
        err = (error ?: err);
        dispatch_group_leave(group);
      }];
    }else {
      [[GBIM shared] joinRoomWithRoomID:roomID complete:^(NSError *error) {
        err = (error ?: err);
        dispatch_group_leave(group);
      }];
    }
    
    // 加入RTC房间
    dispatch_group_enter(group);
    [[GBExpress shared] loginRoomWithID:roomID complete:^(NSError *error) {
      err = (error ?: err);
      dispatch_group_leave(group);
    }];
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
      if (err) {
        complete(err);
        return;
      }
      [[GBExpress shared] createCopyrightMusicWithCompletion:^(NSError *error) {
        complete(error);
      }];
    });
  });
}

#pragma mark - Leave room
- (void)leaveMultipleRooms {
  [self leaveSDKRoomWithCompletion:nil];
  NSString *roomID = self.roomInfo.roomID;
  if (roomID.length > 0) {
    [GBDataProvider leaveRoomWithRoomID:roomID complete:nil];
  }
}

- (void)leaveSDKRoomWithCompletion:(GBErrorBlock)completion {
  [[GBExpress shared] logout];
//  [[GBIM shared] leaveRoomWithCompletion:^(NSError *error) {
//    !completion ?: completion(error);
//  }];
  [[GBIM shared] leaveRoomWithCompletion:nil];
  !completion ?: completion(nil);
}

#pragma mark -
#pragma mark - Private
- (void)loadZegoSDKsWithCompletion:(GBErrorBlock)completionBlock {
  @weakify(self);
  [self.zSDKLoader loadZegoSDKsWithCompletion:^(NSError *error) {
    @strongify(self);
    if (error) {
      [self toastError:@"SDK初始化失败"];
    }else {
//      [self toast:@"SDK初始化完成"];
    }
    completionBlock(error);
  }];
}

- (void)cleanUpSDK {
  GB_ROOM_MANAGER_NOTIFY(kGBSDKRoomWillCleanUpNotificationName)
  [self.zSDKLoader unloadZegoSDKsWithCompletion:^{
    GB_ROOM_MANAGER_NOTIFY(kGBSDKRoomDidCleanUpNotificationName)
  }];
}


- (void)leaveRoomAndCleanUpSDK {
  GB_ROOM_MANAGER_NOTIFY(kGBSDKRoomWillLeaveNotificationName)
  
  @weakify(self);
  [self leaveSDKRoomWithCompletion:^(NSError *error) {
    @strongify(self);
    
    GB_ROOM_MANAGER_NOTIFY(kGBSDKRoomDidLeaveNotificationName)
    self.roomInfo = nil;
    self.runningRoomService = nil;
    [self cleanUpSDK];
  }];
}

#pragma mark - Toast
- (void)toast:(NSString *)msg {
  UIWindow *window = [UIApplication sharedApplication].delegate.window;
  [window makeToast:msg];
}

- (void)toastError:(NSString *)msg {
  UIWindow *window = [UIApplication sharedApplication].delegate.window;
  [window makeToast:msg duration:3 position:nil];
}

@end

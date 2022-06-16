//
//  GBRoomListVM.m
//  KTVGrab
//
//  Created by Vic on 2022/3/12.
//

#import "GBRoomListVM.h"
#import "GBExternalDependency.h"
#import "GBFontsLoader.h"
#import "GBDataProvider.h"
#import <YYKit/YYKit.h>
#import "GBRunningRoomService.h"
#import "GBRoomManager.h"


@interface GBRoomListVM ()

/// 用于分页加载
@property (nonatomic, assign) NSInteger lastRoomCreateTime;

@end

@implementation GBRoomListVM

#pragma mark - Life cycle
- (void)dealloc {
  GB_LOG_D(@"[DEALLOC]%@ dealloc", NSStringFromClass(self.class));
}

#pragma mark - Private
- (void)setup {
  [GBFontsLoader loadFonts];
}

- (void)setDelegate:(id<GBRoomListVMProtocol>)delegate {
  _delegate = delegate;
  // 需要有了代理后再进行 setup, 否则没有代理对象很多操作都会失败
  [self setup];
}

- (NSInteger)lastRoomCreateTime {
  if (_lastRoomCreateTime == 0) {
    _lastRoomCreateTime = [[NSDate date] timeIntervalSince1970] * 1000;
  }
  return _lastRoomCreateTime;
}

#pragma mark -
- (void)enterRoomWithRoomInfo:(GBRoomInfo *)roomInfo complete:(void (^)(NSError * _Nonnull, GBRunningRoomService * _Nonnull))complete {
  @weakify(self);
  [[GBRoomManager shared] enterRoomWithRoomInfo:roomInfo complete:^(BOOL suc, NSError * _Nonnull err, GBRunningRoomService * _Nullable service) {
    @strongify(self);
    if (!err) {
//      [self.delegate toast:@"进入房间成功"];
    }else {
      if (err.code == GBBackendRoomIsFull) {
        [self.delegate toastError:@"体验房间已满6人，请更换或新建房间"];
      }
      else if (err.code == GBBackendRoomNotExists) {
        [self.delegate toastError:@"房间不存在，请刷新列表"];
      }
      else {
        [self.delegate toastError:@"网络异常，请检查网络后重试"];
      }
    }
    if (complete) {
      complete(err, service);
    }
  }];
}

- (void)requestRooms {
  self.lastRoomCreateTime = 0;
  
  @weakify(self);
  [self appendRoomsWithCompletion:^(BOOL suc, NSError *error, NSArray<GBRoomInfo *> *roomList) {
    @strongify(self);
    if (error) {
      [self.delegate toastError:@"房间列表更新失败"];
    }else {
      [self.delegate toast:@"房间列表更新成功"];
      self.roomInfos = roomList.mutableCopy;
    }
    [self.delegate refreshRoomList];
  }];
}

- (void)loadMoreRooms {
  @weakify(self);
  [self appendRoomsWithCompletion:^(BOOL suc, NSError *error, NSArray<GBRoomInfo *> *roomList) {
    @strongify(self);
    if (error) {
      [self.delegate toastError:@"房间列表上拉刷新失败"];
    }else {
      [self.delegate toast:@"房间列表上拉刷新成功"];
      [self.roomInfos appendObjects:roomList];
    }
    [self.delegate refreshRoomList];
  }];
}

- (void)appendRoomsWithCompletion:(void (^)(BOOL suc, NSError *error, NSArray<GBRoomInfo *> *roomList))completionBlock {
  NSUInteger pageCount = 10;
  NSUInteger lastTime = self.lastRoomCreateTime - 1;
  
  @weakify(self);
  [GBDataProvider getRoomListWithCount:pageCount beforeTime:lastTime complete:^(BOOL suc, NSError * _Nullable err, NSArray<GBRoomRespModel *> * respModels) {
    @strongify(self);
    
    NSMutableArray *roomInfos = [NSMutableArray array];
    if (!err) {
      for (GBRoomRespModel *rspModel in respModels) {
        GBRoomInfo *roomInfo = [[GBRoomInfo alloc] init];
        [roomInfo updateWithRoomRespModel:rspModel];;
        [roomInfos addObject:roomInfo];
      }
    }
    if (roomInfos.count > 0) {
      GBRoomInfo *model = roomInfos.lastObject;
      self.lastRoomCreateTime = model.createTime;
    }
    if (completionBlock) {
      completionBlock(suc, err, roomInfos.copy);
    }
  }];
}

@end

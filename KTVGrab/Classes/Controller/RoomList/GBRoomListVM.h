//
//  GBRoomListVM.h
//  KTVGrab
//
//  Created by Vic on 2022/3/12.
//

#import <Foundation/Foundation.h>
#import "GBRoomInfo.h"

@class GBRunningRoomService;

NS_ASSUME_NONNULL_BEGIN

@protocol GBRoomListVMProtocol <NSObject>

/// 基础服务加载完成
- (void)baseServiceSetupComplete;

/// 弹 toast, 持续时间短
- (void)toast:(NSString *)msg;

/// 弹错误提示, 持续时间长
- (void)toastError:(NSString *)msg;

/// 开始转菊花
- (void)startLoading;

/// 停止转菊花
- (void)endLoading;

/// 停止上下拉控件动画
- (void)endUIRefreshing;

/// 刷新房间列表 UI
- (void)refreshRoomList;

@end


@interface GBRoomListVM : NSObject

/// 事件代理对象
@property (nonatomic, weak) id<GBRoomListVMProtocol> delegate;

/// 房间数据模型数组
@property (nonatomic, strong) NSMutableArray<GBRoomInfo *> *roomInfos;

/// 进入房间
- (void)enterRoomWithRoomInfo:(GBRoomInfo *)roomInfo complete:(void(^)(NSError *error, GBRunningRoomService *service))complete;

/// 全量刷新房间列表
- (void)requestRooms;

/// 加载更多房间列表
- (void)loadMoreRooms;

@end

NS_ASSUME_NONNULL_END

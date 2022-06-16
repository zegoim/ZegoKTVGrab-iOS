//
//  GBRoomUserService.h
//  KTVGrab
//
//  Created by Vic on 2022/3/16.
//

#import <Foundation/Foundation.h>
#import "GBUser.h"
#import "GBSDKEventAgent.h"

@class GBRoomUserService;
@class GBSEIModel;
@class GBUserRespModel;
@class GBRoomInfo;
@class GBNetQualityModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * SEI 相关协议
 */
@protocol GBRoomUserSEIListener <NSObject>

/**
 * 收到 SEI 信息
 */
- (void)userService:(GBRoomUserService *)service onReceiveSEI:(GBSEIModel *)model;

@end


/**
 * 本端用户感知
 */
@protocol GBRoomUserAwaringListener <NSObject>

/**
 * 用户自己身份已经确定的回调
 * 可用于刚进房给出提示, 例如:"您当前为麦下用户, 不可参与游戏" 等业务
 */
- (void)userService:(GBRoomUserService *)service onAwaringMyself:(GBUser *)myself;

/**
 * 由于监听了后台的用户列表更新, 在离开房间时, 后台会更新用户列表, 此时可以收到自己已经离开 IM 房间的消息
 */
- (void)userService:(GBRoomUserService *)service onMyselfRemoved:(GBUser *)myself;

@end


/**
 * 用户列表和用户信息监听协议
 */
@protocol GBRoomUserEventListener <NSObject>

/**
 * 用户列表更新回调
 */
- (void)userService:(GBRoomUserService *)service onUserListUpdate:(NSArray<GBUser *> *)userList;

/**
 * 用户零散信息更新回调, 例如: 是否开麦 等用户状态信息更新 (不用更新用户列表)
 */
- (void)userService:(GBRoomUserService *)service onUserMiscUpdate:(GBUser *)user;

/**
 * 用户音浪值更新回调
 */
- (void)userService:(GBRoomUserService *)service onUser:(NSString *)userID soundLevelUpdate:(CGFloat)soundLevel;

/**
 * 用户是否有流, 用于判断是否需要展示该用户的网络状况图标
 */
- (void)userService:(GBRoomUserService *)service onUser:(NSString *)userID streamOnAir:(BOOL)flag;

@end


/**
 * 网络质量相关的监听协议
 */
@protocol GBRoomUserNetQualityListener <NSObject>

/**
 * 测速回调, 用于更新 UI 右上角的网络测速图标
 */
- (void)userService:(GBRoomUserService *)service onMyTestSpeedQualityUpdate:(GBNetQuality)qualityLevel;

/**
 * 用户网络状态更新回调, 用于展示麦位上各用户的网络状态图标(包括自己)
 */
- (void)userService:(GBRoomUserService *)service onUser:(NSString *)userID netQualityLevelUpdate:(GBNetQuality)qualityLevel;

/**
 * 用户实时数据更新回调
 */
- (void)userService:(GBRoomUserService *)service onUser:(NSString *)userID qualityUpdate:(GBNetQualityModel *)quality;

@end

/**
 * 这个类比较杂, 基本上和用户有关的方法都会写在这里
 * 例如: 开关麦克风, 推拉流, 获取用户信息等
 */
@interface GBRoomUserService : NSObject <GBAgentUserUpdateListener>

//TODO: 这里的 roomInfo 目前仅用于获取 roomID, 用于开关麦调用后台接口. 以后可考虑直接使用 RoomManager 获取, 废弃该变量.
@property (nonatomic, strong) GBRoomInfo *roomInfo;

/**
 * 设置监听对象
 */
- (void)setEventListener:(id<GBRoomUserEventListener>)eventListener;
- (void)setUserAwaringListener:(id<GBRoomUserAwaringListener>)userAwaringListener;
- (void)appendSeiListeners:(NSArray<id<GBRoomUserSEIListener>> *)seiListeners;
- (void)appendQualityUpdateListeners:(NSArray<id<GBRoomUserNetQualityListener>> *)listeners;

/**
 * 便利方法, 获取用户自己
 */
- (GBUser *)getMyself;

/**
 * 便利方法, 获取房主信息
 */
- (GBUser *)getRoomHost;

/**
 * 便利方法, 判断自己是否为房主
 */
- (BOOL)isMyselfHost;

/**
 * 根据 userID 获取用户信息
 */
- (GBUser * _Nullable)getUserWithUserID:(NSString *)userID;

/**
 * 强制更新 UserService 的用户列表信息
 */
- (void)forceUpdateUserList:(NSArray<GBUser *> *)userList;

@end


@interface GBRoomUserService (UserAction)

/**
 * 开启自己的麦克风
 */
- (void)startSendingMySoundWithCompletion:(void(^ _Nullable)(BOOL suc))completion;

/**
 * 关闭自己的麦克风
 */
- (void)stopSendingMySoundWithCompletion:(void(^ _Nullable)(BOOL suc))completion;

/**
 * 开始推流
 */
- (void)startSendingMyStream;

/**
 * 停止推流
 */
- (void)stopSendingMyStream;

/**
 * 播放/停止房主流
 */
- (void)playHostStream:(BOOL)play;

/**
 * 检查用户流是否存在
 */
- (BOOL)checkIfUserStreamOnAir:(NSString *)userID;

@end

NS_ASSUME_NONNULL_END

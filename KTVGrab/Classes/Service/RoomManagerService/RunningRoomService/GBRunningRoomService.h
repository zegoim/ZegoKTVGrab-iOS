//
//  GBRunningRoomService.h
//  KTVGrab
//
//  Created by Vic on 2022/3/21.
//

#import <Foundation/Foundation.h>
#import "GBRoomInfo.h"

#import "GBHeartbeatService.h"
#import "GBRoomUserService.h"
#import "GBSDKEventAgent.h"
#import "GBSongResourceProvider.h"
#import "GBMediaPlayer.h"
#import "GBMediaProgressSimulator.h"
#import "GBRoomInfoService.h"
#import "GBSEIService.h"
#import "GBSongListService.h"
#import "GBScoreService.h"
#import "GBSeatService.h"
#import "GBAudioQualityService.h"
#import "GBSDKCnctService.h"

@class GBRunningRoomService;
@class GBSong;
@class GBRoundGrade;
@class GBSeatInfo;
@class GBNetQualityModel;

NS_ASSUME_NONNULL_BEGIN

@protocol GBRunningRoomEvent <NSObject>

/**
 * 房间断开回调
 */
- (void)onRoomDisconnected;

/**
 * 房间正在重连回调
 */
- (void)onRoomReconnecting;

/**
 * 房间已重连回调
 */
- (void)onRoomReconnected;

/**
 * 被踢出房间
 */
- (void)onRoomKickout;

/**
 * 房间状态变化回调
 */
- (void)onRoomStateUpdate:(GBRoomInfo *)roomInfo checkSong:(BOOL)available;

/**
 * 歌曲进度更新回调
 */
- (void)onSongProgressUpdate:(NSInteger)progress;

/**
 * 歌曲下载完毕后, 更新歌曲信息 UI
 * TODO: 方法名不够直观, 需要修改
 */
- (void)onSongInfoUIShouldUpdateWithSongPlay:(GBSongPlay *)songPlay checkSong:(BOOL)checkSong;

/**
 * 根据 SEI 信息更新当前歌曲信息 UI
 * TODO: 方法名不够直观, 需要修改
 */
- (void)onSongInfoUIShouldUpdateBySEIWithSongPlay:(GBSongPlay *)songPlay progress:(NSUInteger)progress;

/**
 * 歌曲演唱音高数据回调
 * @param pitch 音高值
 * @param progress 歌曲播放进度
 */
- (void)onSongPitchUpdate:(int)pitch atProgress:(NSInteger)progress;

/**
 * 麦位列表更新.
 * 需要 reloadData.
 */
- (void)onSeatListUpdate:(NSArray<GBSeatInfo *> *)seatList;

/**
 * 指定麦位数据更新.
 * 不需要刷新列表, 只需要对单个 cell 进行操作.
 */
- (void)onSeatMiscUpdate:(GBSeatInfo *)seat;

/**
 * 给 RoomVC 右上角网络测速用的测速回调, 麦位的网络质量数据在 -[GBRunningRoomEvent onSeatMiscUpdate:] 回调方法的 GBSeatInfo.qualityLevel 中
 */
- (void)onNetSpeedTestQualityUpdate:(GBNetQuality)qualityLevel;

/**
 * 展示当前歌曲不允许抢唱的弹窗.
 * 这个弹窗出现在自己刚进房间的时候就处于正在播放歌曲准备抢麦的阶段.
 * 刚进房的第一首歌由于玩家自己可能需要下载, 且一首歌已经进行到一半, 所以自己不能抢麦.
 */
- (void)alertCurSongGrabNotAllowed;

/**
 * 展示房间已经被销毁, 即将退出房间的弹窗
 */
- (void)alertRoomHasBeenDestroyed;

/**
 * 开始转菊花 loading
 */
- (void)onHudStart;

/**
 * 更新 loading 文本
 */
- (void)onHudTextUpdate:(NSString *)text;

/**
 * loading 结束
 */
- (void)onHudEnd;

/**
 * 弹出 toast
 */
- (void)toastMsg:(NSString *)msg;

@end

@protocol GBRunningRoomLeaveBackendRoomListener <NSObject>

/**
 * 即将离开后台房间回调
 */
- (void)runningRoomService:(GBRunningRoomService *)service willLeaveBackendRoom:(NSString *)roomID;

/**
 * 已经退出后台房间回调
 */
- (void)runningRoomService:(GBRunningRoomService *)service didLeaveBackendRoom:(NSString *)roomID error:(NSError *)error;

@end

@interface GBRunningRoomService : NSObject

@property (nonatomic, strong) GBRoomInfo *roomInfo;

/**
 * GBRunningRoomService 所用到的各种次级的服务
 * 每个 service 类都有对应的注释简要介绍该类的作用
 */
@property (nonatomic, strong, nullable) GBSDKEventAgent           *eventAgent;
@property (nonatomic, strong, nullable) GBHeartbeatService        *heartbeatService;
@property (nonatomic, strong, nullable) GBRoomUserService         *userService;
@property (nonatomic, strong, nullable) GBSongResourceProvider    *songResourceProvider;
@property (nonatomic, strong, nullable) GBMediaPlayer             *mediaPlayer;
@property (nonatomic, strong, nullable) GBMediaProgressSimulator  *mediaProgressSimulator;
@property (nonatomic, strong, nullable) GBRoomInfoService         *roomInfoService;
@property (nonatomic, strong, nullable) GBSongListService         *songListService;
@property (nonatomic, strong, nullable) GBSEIService              *seiService;
@property (nonatomic, strong, nullable) GBScoreService            *scoreService;
@property (nonatomic, strong, nullable) GBSeatService             *seatService;
@property (nonatomic, strong, nullable) GBAudioQualityService     *audioQualityService;
@property (nonatomic, strong, nullable) GBSDKCnctService          *sdkCnctService;

/**
 * 初始化方法
 * @param roomInfo 房间信息
 */
- (instancetype)initWithRoomInfo:(GBRoomInfo *)roomInfo;

/**
 * 设置 GBRunningRoomEvent 协议的事件监听对象
 */
- (void)setDelegate:(id<GBRunningRoomEvent> _Nullable)delegate;

/**
 * 设置 GBRunningRoomLeaveBackendRoomListener 协议的事件监听对象
 */
- (void)setLeaveBackendRoomListener:(id<GBRunningRoomLeaveBackendRoomListener>)listener;

/**
 * 启动服务
 * 第一次进房的时候调用
 */
- (void)start;

/**
 * 退出后台房间
 * 成功退出后台房间后, 才会退出 RTC 和 IM 房间, 然后清理 SDK
 */
- (void)startBackendLeaveRoomProcess;

/**
 * 开始清理 SDK
 */
- (void)startServiceCleanUpProcess;

/**
 * 本地判断是否还有下一轮
 */
- (BOOL)hasAnotherRound;

/**
 * 通知后台变更房间状态, 开始进行这一轮的抢唱
 */
- (void)startRound;

/**
 * 通知后台变更房间状态, 进入下一轮
 * 和 -[GBRunningRoom startRound] 的区别在于:
 * - startRound 是进入了下载歌曲资源, 然后唱歌的环节
 * - enterNextRound 是回到新一轮的开始页面, 需要再次触发 startRound 才能真正开始游戏
 */
- (void)enterNextRound;

/**
 * 抢唱当前歌曲, 抢唱成功后后台会变更房间状态
 */
- (void)grabCurSong;

/**
 * 开关麦克风
 * @param enable 开 / 关
 * @param flag 开关麦克风操作后, 是否需要弹出 toast 提示用户
 */
- (void)enableMicrophone:(BOOL)enable toast:(BOOL)flag;

@end

@interface GBRunningRoomService (FetchInfo)

/**
 * 获取当前高潮片段歌曲完整信息
 */
- (GBSong *)getCurSong;

/**
 * 获取当前高潮片段歌曲后台信息
 */
- (GBSongPlay *)getCurSongPlay;

/**
 * 获取当前抢麦人员用户信息
 */
- (GBUser *)getCurGrabUser;

/**
 * 获取自己用户信息
 */
- (GBUser *)getMyself;

/**
 * 获取房主用户信息
 */
- (GBUser *)getRoomHost;

/**
 * 本人是否为房主
 */
- (BOOL)isMyselfHost;

/**
 * 本人是否为当前已抢麦用户
 */
- (BOOL)isMyselfGrabCurSong;

@end

NS_ASSUME_NONNULL_END

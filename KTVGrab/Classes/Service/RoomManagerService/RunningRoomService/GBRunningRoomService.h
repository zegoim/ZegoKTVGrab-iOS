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
- (void)onSongInfoUIShouldUpdateWithSongPlay:(GBSongPlay *)songPlay;
//TODO:命名需要修改
- (void)onSongInfoUIShouldUpdateWithSongPlay:(GBSongPlay *)songPlay progress:(NSUInteger)progress;
- (void)onSongPitchUpdate:(int)pitch atProgress:(NSInteger)progress;

- (void)onSeatListUpdate:(NSArray<GBSeatInfo *> *)seatList;
- (void)onSeatMiscUpdate:(GBSeatInfo *)seat;
- (void)onNetSpeedTestQualityUpdate:(GBNetQuality)qualityLevel;

- (void)alertCurSongGrabNotAllowed;
- (void)alertRoomHasBeenDestroyed;
- (void)onFirstEntryRoomInfoUpdate:(GBRoomInfo *)roomInfo;

- (void)onHudStart;
- (void)onHudTextUpdate:(NSString *)text;
- (void)onHudEnd;
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


- (instancetype)initWithRoomInfo:(GBRoomInfo *)roomInfo;
- (void)setDelegate:(id<GBRunningRoomEvent> _Nullable)delegate;
- (void)setLeaveBackendRoomListener:(id<GBRunningRoomLeaveBackendRoomListener>)listener;

/**
 * 启动服务
 */
- (void)start;

/**
 * 开始离开后台房间
 */
- (void)startBackendLeaveRoomProcess;

/**
 * 开始清理 SDK
 */
- (void)startServiceCleanUpProcess;

/**
 * 是否还有下一轮
 */
- (BOOL)hasAnotherRound;

/**
 * 开始新一轮抢唱
 */
- (void)startAnotherRound;

/**
 * 抢唱当前歌曲
 */
- (void)grabCurSong;

/**
 * 开关麦克风
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

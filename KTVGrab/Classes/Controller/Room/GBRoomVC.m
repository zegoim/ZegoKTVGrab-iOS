//
//  GBRoomVC.m
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import "GBRoomVC.h"

// Util
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import <Toast/Toast.h>
#import "GBAlert.h"
#import "GBImage.h"
#import "GoHalfModalHeader.h"
#import "NSBundle+KTVGrab.h"
#import <GoKit/GoUIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

// Service
#import "GBRoomManager.h"
#import "GBRunningRoomService.h"

// View
#import "GBBoardContainerView.h"
#import "GBRoomBgView.h"
#import "GBRoomInfoView.h"
#import "GBRoomPanelView.h"
#import "GBGrabMicView.h"
#import "GBSeatsView.h"
#import "GBRoundResultView.h"
#import "GBNetIndicatorView.h"
#import <KTVGrab/KTVGrab-Swift.h>

// View Controller
#import "ZegoAudioConfigVC.h"

// Model
#import "GBSong.h"
#import "GBSongPlay.h"
#import "GBUser.h"
#import "GBNetQualityModel.h"

@interface GBRoomVC ()
<
GBRunningRoomEvent,
GBRunningRoomLeaveBackendRoomListener
>

/// 房间内服务
@property (nonatomic, strong, readonly) GBRunningRoomService *runningRoomService;

@property (nonatomic, strong) GBRoomInfo *roomInfo;

#pragma mark - View
/// 背景 view
@property (nonatomic, strong) GBRoomBgView *bgView;

/// 霓虹背景
@property (nonatomic, strong) UIImageView *bgNeonView;

/// 左上角房间信息
@property (nonatomic, strong) GBRoomInfoView *roomInfoView;

/// 中间上方的信息展示板, 包含几乎所有提示信息
@property (nonatomic, strong) GBBoardContainerView *infoBoard;

/// 星星点缀
@property (nonatomic, strong) UIImageView *starsImageView;

/// 飞线动图
@property (nonatomic, strong) GBLottieView *flywireEffectView;

/// 麦位视图
@property (nonatomic, strong) GBSeatsView *seatsView;

/// 右上角退出房间按钮
@property (nonatomic, strong) UIButton *quitRoomButton;

/// 左下方控制面板 view
@property (nonatomic, strong) GBRoomPanelView *panelView;

/// 网络测速
@property (nonatomic, strong) GBNetIndicatorView *netIndicatorView;

/// 抢唱倒计时 view
@property (nonatomic, weak) GBGrabMicView *grabView;

/// 抢唱一轮结束后的计分板
@property (nonatomic, strong) GBRoundResultView *myRoundGradeView;

/// 音频调节面板
@property (nonatomic, strong) ZegoAudioConfigVC *audioConfigVC;

//@property (nonatomic, copy) NSString *seiUpdateSongID;
@property (nonatomic, assign) int pitchVal;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation GBRoomVC

#pragma mark -
#pragma mark - Life Cycle
- (instancetype)initWithService:(GBRunningRoomService *)runningRoomService {
  if (self = [super init]) {
    [self setRunningRoomService:runningRoomService];
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self registerObservers];
  [self setupUI];
}

- (void)updateViewConstraints {
  [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view);
  }];
  
  [self.bgNeonView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.quitRoomButton);
    make.left.right.equalTo(self.view);
    make.bottom.equalTo(self.infoBoard).offset(30);
  }];
  
  [self.roomInfoView mas_remakeConstraints:^(MASConstraintMaker *make) {
    if (@available(iOS 11.0, *)) {
      make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(15.5);
    } else {
      make.top.equalTo(self.view).offset(15.5 + 20);
    }
    make.left.equalTo(self.view).offset(16);
    make.right.lessThanOrEqualTo(self.netIndicatorView.mas_left).inset(10);
  }];
  
  [self.infoBoard mas_remakeConstraints:^(MASConstraintMaker *make) {
    CGFloat width = CGRectGetWidth(self.view.bounds) - 8 * 2;
    CGFloat height = width * 235.0 / 359.0;
    
    make.size.mas_equalTo(CGSizeMake(width, height));
    make.centerX.equalTo(self.view);
    make.top.equalTo(self.roomInfoView.mas_bottom).offset(29);
  }];
  
  [self.quitRoomButton mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.width.height.mas_equalTo(44);
    make.centerY.equalTo(self.roomInfoView);
    make.right.equalTo(self.view).inset(3);
  }];
  
  [self.netIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.quitRoomButton.mas_left).offset(6);
    make.centerY.equalTo(self.quitRoomButton);
  }];
  
  [self.panelView mas_remakeConstraints:^(MASConstraintMaker *make) {
    if (@available(iOS 11.0, *)) {
      make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).inset(16);
    } else {
      make.bottom.equalTo(self.view).inset(16);
    }
    make.left.equalTo(self.view).offset(16);
  }];
  
  [self.seatsView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.height.mas_equalTo(165).priority(MASLayoutPriorityRequired);
//    make.bottom.equalTo(self.panelView.mas_top).inset(20);
    make.left.equalTo(self.view).offset(12);
    make.right.equalTo(self.view).inset(12);
    make.top.equalTo(self.roomInfoView).offset(376);
  }];
  
  [self.starsImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.view);
    make.top.equalTo(self.infoBoard.mas_bottom).inset(5);
  }];
  
  [self.flywireEffectView mas_remakeConstraints:^(MASConstraintMaker *make) {
//    make.height.equalTo(self.feixianView.mas_width).multipliedBy(338.0 / 375.0);
    make.top.equalTo(self.infoBoard).offset(50);
    make.left.right.equalTo(self.view);
    make.bottom.equalTo(self.seatsView.mas_top).offset(80);
  }];

  [super updateViewConstraints];
}


#pragma mark -
#pragma mark - Private
- (void)showGrabMicView:(BOOL)checkSong {
  if (![[[GBUserAccount shared] getMyAuthority] canGrab]) {
    return;
  }
  
  GBSongPlay *curSongPlay = [self.runningRoomService getCurSongPlay];
  GBSong *curSong = [self.runningRoomService getCurSong];
  NSUInteger curGrabDuration = curSongPlay.firstPartDuration;
  
  @weakify(self);
  GBGrabMicView *grabView = [[GBGrabMicView alloc] initWithGrabDuration:curGrabDuration - 3 grabTriggerBlock:^{
    @strongify(self);
    if ([curSong validateIntegrity]) {
      [self.runningRoomService grabCurSong];
    }else {
      [self toastMsg:@"歌曲资源下载未完成，抢唱失败"];
    }
  }];
  [self.view addSubview:grabView];
  self.grabView = grabView;
  [grabView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self.view);
    make.top.equalTo(self.quitRoomButton.mas_bottom).offset(20);
  }];
}

- (void)showMyRoundGradeViewWithText:(NSString *)text firstEntry:(BOOL)firstEntry {
  GBUser *myself = [self.runningRoomService getMyself];
  GBRoundResultView *view = self.myRoundGradeView;
  [view setUser:myself];
  [view setGrade:myself.grade];
  BOOL flag = [self.runningRoomService hasAnotherRound];
  if (self.runningRoomService.roomInfo.roomState == GBRoomStateRoomExit) {
    flag = NO;
  }
  [view setHasAnotherRound:flag];
  [view setText:text];
  view.spectatorMode = firstEntry;
  [self.view addSubview:view];
}

- (GBRoundResultView *)myRoundGradeView {
  if (!_myRoundGradeView) {
    GBRoundResultView *view = [[GBRoundResultView alloc] initWithFrame:self.view.bounds];
    @weakify(self);
    view.onClickLeaveRoom = ^{
      @strongify(self);
      if (self.runningRoomService.roomInfo.roomState == GBRoomStateRoomExit) {
        [self.runningRoomService startServiceCleanUpProcess];
      }else {
        [self onClickCloseButton];
      }
    };
    
    view.onClickAnotherRound = ^{
      @strongify(self);
      [self.runningRoomService enterNextRound];
    };
    _myRoundGradeView = view;
  }
  return _myRoundGradeView;
}

#pragma mark - UI Setup
- (void)setupUI {
  self.view.backgroundColor = UIColor.whiteColor;
  [self setupSubviews];
}

- (void)setupSubviews {
  [self.view addSubview:self.bgView];
  [self.view addSubview:self.flywireEffectView];
  [self.view addSubview:self.bgNeonView];
  [self.view addSubview:self.starsImageView];
  [self.view addSubview:self.roomInfoView];
  [self.view addSubview:self.infoBoard];
  [self.view addSubview:self.seatsView];
  [self.view addSubview:self.netIndicatorView];
  [self.view addSubview:self.quitRoomButton];
  [self.view addSubview:self.panelView];
}

- (void)updateUI {
  [self.roomInfoView setRoomName:self.runningRoomService.roomInfo.roomName];
  [self.roomInfoView setUser:[self.runningRoomService getRoomHost]];
}

- (void)registerObservers {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSDKRoomWillLeaveNotification) name:kGBSDKRoomWillLeaveNotificationName object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSDKRoomDidLeaveNotification) name:kGBSDKRoomDidLeaveNotificationName object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSDKRoomWillCleanUpNotification) name:kGBSDKRoomWillCleanUpNotificationName object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSDKRoomDidCleanUpNotification) name:kGBSDKRoomDidCleanUpNotificationName object:nil];
}

- (void)updateUIWithRoomInfo:(GBRoomInfo *)roomInfo checkSong:(BOOL)checkSong {
  BOOL firstEntry = ({
    BOOL isFirst = NO;
    if (!self.roomInfo || self.roomInfo.roomState == GBRoomStateUnknown) {
      isFirst = YES;
    }
    isFirst;
  });
  
  self.roomInfo = roomInfo;
  
  GBRoomState roomState = roomInfo.roomState;
  GBSong *curSongInfo = [self.runningRoomService getCurSong];
  GBUser *grabUser = [self.runningRoomService getCurGrabUser];
  
  if (roomInfo.roomState == GBRoomStateGrabWaiting) {
    GB_LOG_E(@"[BUG] -[%@ %@] GBRoomStateGrabWaiting. Song:%@, SongID: %@, SongName: %@, checkSong: %d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), curSongInfo, curSongInfo.songID, curSongInfo.songName, checkSong);
  }
  
  [self.infoBoard setGrabUser:grabUser];
  [self.infoBoard setSong:curSongInfo];
  [self.infoBoard setRoomInfo:self.runningRoomService.roomInfo checkSong:checkSong];
  
  [self.panelView setMicEnable:NO];
  [self.panelView setAudioConfigVisible:YES];
  
  [self.flywireEffectView stop];
  
  self.pitchVal = 0;
  [self.grabView removeFromSuperview];

  if (roomState != GBRoomStateRoomExit) {
    [self.myRoundGradeView removeFromSuperview];
  }
  
  switch (roomState) {
    case GBRoomStateUnknown: {
      break;
    }
    case GBRoomStateGameWaiting:
    case GBRoomStateRoundPreparing:
      [self.panelView setMicEnable:YES];
      break;

    case GBRoomStateGrabWaiting:
    {
      if (!firstEntry) {
        [self showGrabMicView:checkSong];
      }
      [self.flywireEffectView play];
    }
      break;
      
    case GBRoomStateGrabSuccessfully:
    case GBRoomStateSinging:
    {
      [self.panelView setMicEnable:[self.runningRoomService isMyselfGrabCurSong]];
      [self.flywireEffectView play];
    }
      break;
      
    case GBRoomStateGrabUnsuccessfully:
    case GBRoomStateAIScoring:
    case GBRoomStateSongEnd:
    case GBRoomStateNextSongPreparing:
    {
      [self.panelView setMicEnable:NO];
      break;
    }
    case GBRoomStateRoundEnd:
    {
      [self.panelView setMicEnable:NO];
      NSString *text = @"";
      if (![self.runningRoomService isMyselfHost] && [self.runningRoomService hasAnotherRound]) {
          text = @"等待房主开始新的一局...";
      }
      [self showMyRoundGradeViewWithText:text firstEntry:firstEntry];
    }
      break;
    case GBRoomStateRoomExit:
    {
      [self.panelView setMicEnable:NO];
      [self onRoomExit];
      break;
    }
  }
}

#pragma mark View
- (GBRoomBgView *)bgView {
  if (!_bgView) {
    _bgView = [[GBRoomBgView alloc] init];
  }
  return _bgView;
}

- (UIImageView *)bgNeonView {
  if (!_bgNeonView) {
    _bgNeonView = [[UIImageView alloc] init];
    _bgNeonView.image = [GBImage imageNamed:@"gb_info_board_bg_neon"];
  }
  return _bgNeonView;
}

- (GBRoomInfoView *)roomInfoView {
  if (!_roomInfoView) {
    _roomInfoView = [[GBRoomInfoView alloc] init];
  }
  return _roomInfoView;
}

- (GBBoardContainerView *)infoBoard {
  if (!_infoBoard) {
    _infoBoard = [[GBBoardContainerView alloc] init];
    @weakify(self);
    _infoBoard.onClickStartGameButton = ^{
      @strongify(self);
      [self.runningRoomService startRound];
    };
  }
  return _infoBoard;
}

- (UIButton *)quitRoomButton {
  if (!_quitRoomButton) {
    _quitRoomButton = [[UIButton alloc] init];
    [_quitRoomButton addTarget:self action:@selector(onClickCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [_quitRoomButton setImage:[GBImage imageNamed:@"gb_close_round"] forState:UIControlStateNormal];
  }
  return _quitRoomButton;
}

- (GBNetIndicatorView *)netIndicatorView {
  if (!_netIndicatorView) {
    _netIndicatorView = [[GBNetIndicatorView alloc] init];
  }
  return _netIndicatorView;
}

- (GBRoomPanelView *)panelView {
  if (!_panelView) {
    GBRoomPanelView *view = [[GBRoomPanelView alloc] init];
    @weakify(self);
    view.shouldModalAudioConfigPanel = ^{
      @strongify(self);
      [self presentAudioConfigVC];
    };
    view.shouldOpenMicrophone = ^(BOOL on) {
      @strongify(self);
      [self enableUIMicrophone:on toast:YES];
    };
    view.alertMicIsDisabled = ^{
      @strongify(self);
      [GoNotice showToast:@"为了演唱效果,暂不支持开麦" onView:self.view];
    };
    
    _panelView = view;
  }
  return _panelView;
}

- (GBSeatsView *)seatsView {
  if (!_seatsView) {
    _seatsView = [[GBSeatsView alloc] init];
    _seatsView.seatsCount = self.runningRoomService.roomInfo.seatsCount;
    _seatsView.columns = MIN(3, _seatsView.seatsCount);
  }
  return _seatsView;
}

- (UIImageView *)starsImageView {
  if (!_starsImageView) {
    _starsImageView = [[UIImageView alloc] init];
    _starsImageView.image = [GBImage imageNamed:@"gb_bg_stars"];
  }
  return _starsImageView;
}

- (GBLottieView *)flywireEffectView {
  if (!_flywireEffectView) {
    GBLottieView *view = [[GBLottieView alloc] initWithImageProvideBundle:[NSBundle GB_bundle]];
    [view namedWithName:@"feixian" bundle:[NSBundle GB_bundle]];
    _flywireEffectView = view;
  }
  return _flywireEffectView;
}

- (ZegoAudioConfigVC *)audioConfigVC {
  if (!_audioConfigVC) {
    _audioConfigVC = [ZegoAudioConfigVC loadVCFromNib];
  }
  return _audioConfigVC;
}

- (MBProgressHUD *)hud {
  if (!_hud) {
    MBProgressHUD *view = [[MBProgressHUD alloc] initWithView:self.view];
    view.removeFromSuperViewOnHide = YES;
    view.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    view.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.1f];
    view.graceTime = 0.5;
    [self.view addSubview:view];
    _hud = view;
  }
  return _hud;
}

- (void)showHud:(MBProgressHUD *)hud {
  UIWindow *window = [UIApplication sharedApplication].keyWindow;
  [window addSubview:hud];
  [hud showAnimated:YES];
}

#pragma mark - Action
- (void)onClickCloseButton {
  if ([self.runningRoomService isMyselfHost]) {
    [self alertDestroyRoom];
  }else {
    [self.runningRoomService startBackendLeaveRoomProcess];
  }
}

- (void)presentAudioConfigVC {
  [GoHalfModalPresentationCoordinator presentWithPresentedVC:self presentingVC:self.audioConfigVC animated:YES completion:nil];
}

- (void)enableUIMicrophone:(BOOL)enable toast:(BOOL)flag {
  [self.runningRoomService enableMicrophone:enable toast:flag];
}

#pragma mark - Notification handle
- (void)didReceiveSDKRoomWillLeaveNotification {
//  self.hud.label.text = @"正在退出SDK房间...";
  [self showHud:self.hud];
}

- (void)didReceiveSDKRoomDidLeaveNotification {
//  self.hud.label.text = @"退出SDK房间完成";
}

- (void)didReceiveSDKRoomWillCleanUpNotification {
//  self.hud.label.text = @"正在清理SDK...";
}

- (void)didReceiveSDKRoomDidCleanUpNotification {
//  self.hud.label.text = @"SDK清理完毕";
  [self.hud hideAnimated:YES];
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Quit Room
- (void)onRoomExit {
  if ([self.runningRoomService isMyselfHost]) {
    //房主
    [self resolveGrabViewPopUpWithText:nil];
  }else {
    [self alertRoomHasBeenDestroyed];
  }
}

- (void)resolveGrabViewPopUpWithText:(NSString *)text {
  if (self.myRoundGradeView.superview) {
    [self.runningRoomService startServiceCleanUpProcess];
  }else {
    [self showMyRoundGradeViewWithText:text firstEntry:NO];
  }
}

#pragma mark - Alert
- (void)alertDestroyRoom {
  GBAlert *alert = [GBAlert alert];
  [alert configWithTitle:@"退出房间"
                 content:@"退出房间后, 该房间将会解散"
         leftActionTitle:@"取消"
              leftAction:^{
    
  }
        rightActionTitle:@"确认"
             rightAction:^{
    [self.runningRoomService startBackendLeaveRoomProcess];
  }];
  [alert show];
}

- (void)alertRoomHasBeenDestroyed {
  GBAlert *alert = [GBAlert alert];
  [alert configWithTitle:@"房间已被解散" content:@"房主已退出房间, 房间将自动解散" actionTitle:@"确认" action:^{
    [self resolveGrabViewPopUpWithText:@"房主已退出房间，房间将自动解散"];
  }];
  [alert show];
}

- (void)alertRoomDisconnected {
  GBAlert *alert = [GBAlert alert];
  [alert configWithTitle:@"网络异常" content:@"网络无法连接, 请离开房间后再试" actionTitle:@"确认" action:^{
    [self.runningRoomService startServiceCleanUpProcess];
  }];
  [alert show];
}

- (void)alertCurSongGrabNotAllowed {
  GBAlert *alert = [GBAlert alert];
  [alert configWithTitle:nil content:@"本轮抢唱游戏已开始,做好准备下一首即可参与抢麦" actionTitle:@"确定" action:nil];
  [alert show];
}

#pragma mark - Setter & Getter
- (void)setRunningRoomService:(GBRunningRoomService *)runningRoomService {
  _runningRoomService = runningRoomService;
  [runningRoomService setDelegate:self];
  [runningRoomService setLeaveBackendRoomListener:self];
  [runningRoomService start];
  
  [self updateUI];
}

#pragma mark - GBRunningRoomEvent
- (void)toastMsg:(NSString *)msg {
  [self.view makeToast:msg duration:2 position:CSToastPositionCenter];
}

- (void)onRoomDisconnected {
  self.hud.label.text = @"重连失败";
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self.hud hideAnimated:YES];
    [self alertRoomDisconnected];
  });
}

- (void)onRoomReconnecting {
  self.hud.label.text = @"网络异常,正在等待重连";
  [self showHud:self.hud];
  [self.hud hideAnimated:YES afterDelay:GB_NET_TIME_OUT_SECOND];
}

- (void)onRoomReconnected {
  self.hud.label.text = @"重连成功";
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self.hud hideAnimated:YES];
  });
}

- (void)onRoomKickout {
  [self toastMsg:@"账号在其他地方登录"];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self.runningRoomService startServiceCleanUpProcess];
  });
}

- (void)onRoomStateUpdate:(GBRoomInfo *)roomInfo checkSong:(BOOL)available {
  [self.audioConfigVC setRoomInfo:roomInfo];
  [self updateUIWithRoomInfo:roomInfo checkSong:available];
}

- (void)onSongProgressUpdate:(NSInteger)progress {
  [self.infoBoard setProgress:progress pitch:self.pitchVal];
}

- (void)onSongInfoUIShouldUpdateWithSongPlay:(GBSongPlay *)songPlay checkSong:(BOOL)checkSong {
  GBSong *curSongInfo = [self.runningRoomService getCurSong];
  [self.infoBoard setSong:curSongInfo];
  [self.infoBoard setRoomInfo:self.runningRoomService.roomInfo checkSong:checkSong];
}

/// 根据 SEI 信息进行更新
- (void)onSongInfoUIShouldUpdateBySEIWithSongPlay:(GBSongPlay *)songPlay progress:(NSUInteger)progress {
  /// 只刷新一次
  [self.infoBoard setProgress:progress pitch:0];
}

- (void)onSongPitchUpdate:(int)pitch atProgress:(NSInteger)progress {
  self.pitchVal = pitch;
}

- (void)onSeatListUpdate:(NSArray<GBSeatInfo *> *)seatList {
  [self.seatsView updateSeatList:seatList];
}

- (void)onSeatMiscUpdate:(GBSeatInfo *)seat {
  [self.seatsView updateSeatMisc:seat];
}

- (void)onNetSpeedTestQualityUpdate:(GBNetQuality)qualityLevel {
  [self.netIndicatorView setNetworkQuality:qualityLevel];
}

#pragma mark - GBRunningRoomLeaveBackendRoomListener
- (void)onHudStart {
  [self onHudEnd];
  [self showHud:self.hud];
}

- (void)onHudTextUpdate:(NSString *)text {
  self.hud.label.text = text;
}

- (void)onHudEnd {
  [self.hud hideAnimated:YES];
}

@end

//
//  GBRoomListVC.m
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import "GBRoomListVC.h"

//View
#import "GBEmptyRoomPromptView.h"
#import "GoGradientButton.h"
#import "GBRoomListCell.h"

//VC
#import "GBRoomVC.h"
#import "GBCreateRoomVC.h"

//Util
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import <Toast/Toast.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "GBImage.h"
#import "MJRefresh.h"
#import <GoKit/GoUtils.h>
#import "GBAlert.h"

// Service
#import "GBRoomManager.h"
#import "GoHalfModalHeader.h"
#import "GBDataProvider.h"
#import "GBExternalDependency.h"

#define GB_ROOM_LIST_COLLECTION_H_SPACING 16  //CollectionView 距离屏幕左右的边距
#define GB_ROOM_LIST_CELL_ID              @"GBRoomListCellID"

@interface GBRoomListVC ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
GBRoomListVMProtocol
>

@property (nonatomic, strong) GBRoomListVM *viewModel;
@property (nonatomic, strong) GBCreateRoomVC *createRoomVC;

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) GBEmptyRoomPromptView *emptyRoomPromptView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) GoGradientButton *createRoomButton;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation GBRoomListVC

- (instancetype)initWithViewModel:(GBRoomListVM *)viewModel {
  self = [super init];
  if (self) {
    _viewModel = viewModel;
    viewModel.delegate = self;
  }
  return self;
}

#pragma mark -
#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = NO;
  
  [self autoRefreshRooms];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setup];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  [self makeConstraints];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark - Private
- (void)setup {
  [self setupUI];
  [self setupToast];
//  [self requestMediaAuthority];
}

- (void)setupToast {
  [CSToastManager setQueueEnabled:YES];
  [CSToastManager setDefaultDuration:1];
  [CSToastManager setDefaultPosition:CSToastPositionCenter];
}

- (void)requestMediaAuthority {
  BOOL micDetermined = [GoAuthorityCheck isMicrophoneAuthorizationDetermined];
  if (!micDetermined) {
    [GoAuthorityCheck alertSystemRecordPermissionRequestWithCompletion:nil];
  }else {
    if (![GoAuthorityCheck isMicrophoneAuthorized]) {
      GBAlert *alert = [GBAlert alert];
      [alert configWithTitle:@"权限申请"
                     content:@"请在系统设置中开启麦克风使用权限"
             leftActionTitle:@"取消"
                  leftAction:nil
            rightActionTitle:@"去设置"
                 rightAction:^{
        [GoAppRouter openAppSettings];
      }];
      [alert show];
    }
  }
}

#pragma mark - UI Setup
- (void)setupUI {
  self.view.backgroundColor = UIColor.whiteColor;
  self.title = @"抢唱";
  
  [self setupNavigationBar];
  [self setupSubviews];
}

- (void)setupNavigationBar {
  self.navigationController.navigationBar.translucent = YES;
  [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
  [self.navigationController.navigationBar setShadowImage:[UIImage new]];
  
  UIButton *backButton = [[UIButton alloc] init];
  [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
  [backButton setImage:[GBImage imageNamed:@"ktv_nav_back"] forState:UIControlStateNormal];
  [backButton setTitle:@"" forState:UIControlStateNormal];
  UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
  self.navigationItem.leftBarButtonItems = @[backItem];
  
  [self.navigationController.navigationBar setTitleTextAttributes:@{
    NSForegroundColorAttributeName: [UIColor whiteColor],
  }];
}

- (void)setupSubviews {
  [self.view addSubview:self.bgImageView];
  [self.view addSubview:self.emptyRoomPromptView];
  [self.view addSubview:self.collectionView];
  [self.view addSubview:self.createRoomButton];
}

- (void)makeConstraints {
  [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view);
  }];
  
  [self.emptyRoomPromptView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view);
  }];
  
  [self.createRoomButton mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.view);
    make.size.mas_equalTo(CGSizeMake(144, 36));
    if (@available(iOS 11.0, *)) {
      make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).inset(32);
    }else {
      make.bottom.equalTo(self.view).inset(32);
    }
  }];
  
  [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
    if (@available(iOS 11.0, *)) {
      make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(16);
    }else {
      make.top.equalTo(self.view).offset(16 + 66);
    }
    make.left.equalTo(self.view).offset(GB_ROOM_LIST_COLLECTION_H_SPACING);
    make.right.equalTo(self.view).inset(GB_ROOM_LIST_COLLECTION_H_SPACING);
    make.bottom.equalTo(self.view);
  }];
  
  self.createRoomButton.layer.cornerRadius = 18;
  self.createRoomButton.layer.masksToBounds = YES;
}


#pragma mark Views
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

- (GBCreateRoomVC *)createRoomVC {
  if (!_createRoomVC) {
    GBCreateRoomVC *vc = [GBCreateRoomVC loadVCFromNib];
    @weakify(vc);
    @weakify(self);
    vc.onClickJoinRoomButton = ^(NSString * _Nonnull roomName, NSString * _Nonnull userName) {
      @strongify(vc);
      @strongify(self);
      if (!(roomName.length > 0)) {
        [self toast:@"请输入房间名"];
        return;
      }
      if (!(userName.length > 0)) {
        [self toast:@"请输入用户名"];
        return;
      }
      [GBExternalDependency shared].userName = userName;
      [self createRoomWithRoomName:roomName];
      [vc dismissViewControllerAnimated:YES completion:nil];
    };
    _createRoomVC = vc;
  }
  return _createRoomVC;
}

- (UIImageView *)bgImageView {
  if (!_bgImageView) {
    _bgImageView = [[UIImageView alloc] init];
    _bgImageView.image = [GBImage imageNamed:@"gb_list_bg"];
  }
  return _bgImageView;
}

- (GBEmptyRoomPromptView *)emptyRoomPromptView {
  if (!_emptyRoomPromptView) {
    _emptyRoomPromptView = [[GBEmptyRoomPromptView alloc] init];
  }
  return _emptyRoomPromptView;
}

- (GoGradientButton *)createRoomButton {
  if (!_createRoomButton) {
    _createRoomButton = [[GoGradientButton alloc] init];
    [_createRoomButton setImage:[GBImage imageNamed:@"gb_room_join"] forState:UIControlStateNormal];
    [_createRoomButton setTitle:@"创建房间" forState:UIControlStateNormal];
    [_createRoomButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_createRoomButton addTarget:self action:@selector(showCreateRoomVC) forControlEvents:UIControlEventTouchUpInside];
    _createRoomButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    _createRoomButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
  }
  return _createRoomButton;
}

- (UICollectionView *)collectionView {
  if (!_collectionView) {
    
    CGFloat itemSideLength = (kScreenWidth - 2 * GB_ROOM_LIST_COLLECTION_H_SPACING - 10) * 0.5;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemSideLength, itemSideLength);
    layout.minimumInteritemSpacing = 0;
    
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    cv.backgroundColor = UIColor.clearColor;
    [cv registerClass:[GBRoomListCell class] forCellWithReuseIdentifier:GB_ROOM_LIST_CELL_ID];
    cv.delegate = self;
    cv.dataSource = self;
    cv.showsVerticalScrollIndicator = NO;
    cv.mj_insetB = 70;

    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownToRefresh)];
    MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullUpToLoadMore)];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    cv.mj_header = header;
    cv.mj_footer = footer;
    
    _collectionView = cv;
  }
  return _collectionView;
}

#pragma mark - Actions

// 下拉刷新
- (void)pullDownToRefresh {
  [self.viewModel requestRooms];
}

// 上拉加载更多
- (void)pullUpToLoadMore {
  [self.viewModel loadMoreRooms];
}

- (void)autoRefreshRooms {
  [self.collectionView.mj_header beginRefreshing];
}

- (void)showCreateRoomVC {
  GBCreateRoomVC *vc = self.createRoomVC;
  [GoHalfModalPresentationCoordinator presentWithPresentedVC:self presentingVC:vc];
}

- (void)goBack {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)createRoomWithRoomName:(NSString *)roomName {
  GBRoomInfo *roomInfo = [[GBRoomInfo alloc] init];
  roomInfo.roomName = roomName;
  roomInfo.rounds = GB_CREATE_ROOM_ROUNDS;
  roomInfo.songsPerRound = GB_CREATE_ROOM_SONGS_PER_ROUND;
  roomInfo.imgURLString = [self getRoomImageURLStringFromUserID:[GBExternalDependency shared].userID];

  [self enterRoomWithRoomInfo:roomInfo];
}

- (NSString *)getRoomImageURLStringFromUserID:(NSString *)userID {
  return [NSString stringWithFormat:GB_ROOM_BG_IMAGE_PATH_FORMAT, [userID intValue] % 16];
}

#pragma mark - Private
- (void)enterRoomWithRoomInfo:(GBRoomInfo *)roomInfo {
  [self onHudStart];
  [self.hud hideAnimated:YES afterDelay:10];
  @weakify(self);
  [self.viewModel enterRoomWithRoomInfo:roomInfo complete:^(NSError * _Nonnull error, GBRunningRoomService * _Nonnull service) {
    @strongify(self);
    [self onHudEnd];
    if (!error) {
      [GBRoomManager shared].runningRoomService = service;
      GBRoomVC *roomVC = [[GBRoomVC alloc] initWithService:service];
      [self.navigationController pushViewController:roomVC animated:YES];
    }
  }];
}

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

- (void)showHud:(MBProgressHUD *)hud {
  UIWindow *window = [UIApplication sharedApplication].keyWindow;
  [window addSubview:hud];
  [hud showAnimated:YES];
}

#pragma mark -
#pragma mark - Protocols
#pragma mark - GBRoomListVMProtocol
- (void)toast:(NSString *)msg {
  UIWindow *window = [[UIApplication sharedApplication].delegate window];
  [window makeToast:msg];
}

- (void)toastError:(NSString *)msg {
  UIWindow *window = [[UIApplication sharedApplication].delegate window];
  [window makeToast:msg duration:3 position:nil];
}

- (void)endUIRefreshing {
  [self.collectionView.mj_header endRefreshing];
  [self.collectionView.mj_footer endRefreshing];
}

- (void)refreshRoomList {
  [self.collectionView reloadData];
  self.emptyRoomPromptView.hidden = (self.viewModel.roomInfos.count > 0);
  [self endUIRefreshing];
}

#pragma mark - UICollection Protocols
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.viewModel.roomInfos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  GBRoomListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GB_ROOM_LIST_CELL_ID forIndexPath:indexPath];
  GBRoomListCellVM *cellVM = [[GBRoomListCellVM alloc] init];
  cellVM.roomInfo = self.viewModel.roomInfos[indexPath.item];
  cell.viewModel = cellVM;
  cell.backgroundColor = UIColor.whiteColor;
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  self.collectionView.userInteractionEnabled = NO;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    self.collectionView.userInteractionEnabled = YES;
  });
  [GBExternalDependency shared].userName = [self getRandomUserName];
  GBRoomInfo *roomInfo = self.viewModel.roomInfos[indexPath.item];
  [self enterRoomWithRoomInfo:roomInfo];
}

- (NSString *)getRandomUserName {
  int random = 100 + arc4random_uniform(900);
  return [NSString stringWithFormat:@"观众 %d", random];
}

@end

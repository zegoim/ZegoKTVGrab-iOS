//
//  GBCreateRoomVC.m
//  KTVGrab
//
//  Created by Vic on 2022/3/7.
//

#import "GBCreateRoomVC.h"
#import <Masonry/Masonry.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "GoGradientButton.h"
#import <YYKit/YYKit.h>
#import <GoKit/GoUIKit.h>
#import <MessageThrottle/MessageThrottle.h>
#import "GBTitleTextField.h"

static int const kGBRoomNameMaxCharNum = 20;
static int const kGBUserNameMaxCharNum = 10;

@interface GBCreateRoomVC ()<UITextFieldDelegate>

@property (nonatomic, strong) GBTitleTextField *userNameField;
@property (nonatomic, strong) GBTitleTextField *roomNameField;
@property (nonatomic, strong) GoGradientButton *joinRoomButton;

@end

@implementation GBCreateRoomVC

- (void)viewDidLoad {
    [super viewDidLoad];

  //弹窗限流
  __unused MTRule *rule = [self mt_limitSelector:@selector(showMaxCharExceedToast)
                                 oncePerDuration:0.2
                                       usingMode:MTPerformModeLast
                                  onMessageQueue:dispatch_get_main_queue()];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.userNameField setText:[self getRandomUserName]];
  [self.roomNameField setText:[self getRandomRoomName]];
}

- (GoGradientButton *)joinRoomButton {
  if (!_joinRoomButton) {
    _joinRoomButton = [[GoGradientButton alloc] init];
    [_joinRoomButton setTitle:@"创建房间" forState:UIControlStateNormal];
    [_joinRoomButton addTarget:self action:@selector(didClickJoinRoomButton) forControlEvents:UIControlEventTouchUpInside];
  }
  return _joinRoomButton;
}

- (GBTitleTextField *)roomNameField {
  if (!_roomNameField) {
    GBTitleTextField *view = [[GBTitleTextField alloc] init];
    [view setTitle:@"房间名"];
    [view setText:[self getRandomRoomName]];
    [view setTextFieldPlaceholder:[NSString stringWithFormat:@" 最大支持 %d 个字", kGBRoomNameMaxCharNum]];
    [view setTextFieldReturnKeyType:UIReturnKeyNext];
    
    @weakify(self);
    @weakify(view);
    view.onTextFieldEditingBlock = ^(NSString * _Nonnull text) {
      @strongify(self);
      @strongify(view);
      int maxWordCount = kGBRoomNameMaxCharNum;
      if (text.length > maxWordCount) {
        view.text = [text substringToIndex:maxWordCount];
        [self showMaxCharExceedToast];
      }
    };
    
    view.onTextFieldShouldReturnBlock = ^{
      @strongify(self);
      @strongify(view);
      [view resignFirstResponder];
      [self.userNameField becomeFirstResponder];
    };
    
    _roomNameField = view;
  }
  return _roomNameField;
}

- (GBTitleTextField *)userNameField {
  if (!_userNameField) {
    GBTitleTextField *view = [[GBTitleTextField alloc] init];
    [view setTitle:@"用户名"];
    [view setText:[self getRandomUserName]];
    [view setTextFieldReturnKeyType:UIReturnKeyJoin];
    
    @weakify(self);
    @weakify(view);
    view.onTextFieldEditingBlock = ^(NSString * _Nonnull text) {
      @strongify(view);
      int maxWordCount = kGBUserNameMaxCharNum;
      if (text.length > maxWordCount) {
        view.text = [text substringToIndex:maxWordCount];
      }
    };
    
    view.onTextFieldShouldReturnBlock = ^{
      @strongify(self);
      [self didClickJoinRoomButton];
    };
    
    _userNameField = view;
  }
  return _userNameField;
}

- (NSString *)getRandomUserName {
  int random = 100 + arc4random_uniform(900);
  return [NSString stringWithFormat:@"房主 %d", random];
}

- (NSString *)getRandomRoomName {
  int random = 100 + arc4random_uniform(900);
  return [NSString stringWithFormat:@"在线 KTV 房间 %d", random];
}

#pragma mark - Protocol
- (CGFloat)presentingHeight {
  CGFloat safeAreaBottomHeight = 0;
  if (@available(iOS 11.0, *)) {
    safeAreaBottomHeight = self.view.safeAreaInsets.bottom;
  }
  return 275 + safeAreaBottomHeight;
}

/// 配置实际内容, 主要是添加 subviews
- (void)setupContentView:(UIView *)contentView {
  [contentView addSubview:self.userNameField];
  [contentView addSubview:self.roomNameField];
  [contentView addSubview:self.joinRoomButton];
  
  [self.roomNameField mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(contentView).offset(10);
    make.left.equalTo(contentView).offset(22);
    make.right.equalTo(contentView).inset(22);
  }];
  
  [self.userNameField mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.roomNameField.mas_bottom).offset(22);
    make.left.right.equalTo(self.roomNameField);
  }];
  
  [self.joinRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.userNameField);
    make.height.mas_equalTo(44);
    make.centerX.equalTo(contentView);
    make.top.equalTo(self.userNameField.mas_bottom).offset(24);
  }];
  
  self.joinRoomButton.layer.cornerRadius = 10;
  self.joinRoomButton.layer.masksToBounds = YES;
}

#pragma mark - UITextField Action & Delegate
- (void)showMaxCharExceedToast {
  UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
  NSString *message = [NSString stringWithFormat:@"房间名仅支持%d个字符", kGBRoomNameMaxCharNum];
  [GoNotice showToast:message duration:2 onView:mainWindow position:GoNoticePositionTop];
}

- (void)didClickJoinRoomButton {
  self.onClickJoinRoomButton(self.roomNameField.text,
                             self.userNameField.text);
}

@end

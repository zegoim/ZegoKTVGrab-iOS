//
//  GBGameWaitingView.m
//  AFNetworking
//
//  Created by Vic on 2022/2/23.
//

#import "GBGameWaitingView.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import "GoGradientButton.h"

@interface GBGameWaitingView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *waitingLabel;
@property (nonatomic, strong) GoGradientButton *startButton;

@end

@implementation GBGameWaitingView

+ (BOOL)requiresConstraintBasedLayout {
  return YES;;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = UIColor.clearColor;
  }
  return self;
}

- (void)updateConstraints {
  BOOL isHost = self.role == GBUserRoleTypeHost;
  
  self.startButton.hidden = !isHost;
  self.waitingLabel.hidden = isHost;
  
  [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self).offset(41);
    make.centerX.equalTo(self);
  }];
  
  [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
    make.centerX.equalTo(self);
  }];
  
  [self.waitingLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self);
    make.top.equalTo(self.contentLabel.mas_bottom).offset(24);
  }];
  
  [self.startButton mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self);
    make.top.equalTo(self.contentLabel.mas_bottom).offset(30);
    make.size.mas_equalTo(CGSizeMake(102, 36));
  }];
  
  [self.startButton.layer setCornerRadius:18];
  [self.startButton.layer setMasksToBounds:YES];
  
  [super updateConstraints];
}

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    UILabel *view = [[UILabel alloc] init];
    view.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    view.textColor = [UIColor whiteColor];
    view.text = @"抢唱规则";
    [self addSubview:view];
    _titleLabel = view;
  }
  return _titleLabel;
}

- (UILabel *)contentLabel {
  if (!_contentLabel) {
    UILabel *view = [[UILabel alloc] init];
    view.font = [UIFont systemFontOfSize:14];
    view.textColor = [UIColor whiteColor];
    view.alpha = 0.8;
    view.numberOfLines = 0;
    view.text = @"系统播放演唱歌曲，抢到麦的用户进行演\n唱，挑战结束后会显示分数";
    [self addSubview:view];
    
    // 调整行间距至 20 行高
    CGFloat lineHeight = 20;
    CGFloat lineSpacing = (lineHeight - view.font.lineHeight) * 2;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = lineSpacing;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    view.attributedText = [[NSAttributedString alloc] initWithString:view.text attributes:attributes];
    
    _contentLabel = view;
  }
  return _contentLabel;
}

- (UILabel *)waitingLabel {
  if (!_waitingLabel) {
    UILabel *view = [[UILabel alloc] init];
    view.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    view.textColor = [UIColor colorWithHexString:@"#FF3571FF"];
    view.text = @"请等待房主开始本轮游戏…";
    [self addSubview:view];
    _waitingLabel = view;
  }
  return _waitingLabel;
}

- (GoGradientButton *)startButton {
  if (!_startButton) {
    GoGradientButton *view = [[GoGradientButton alloc] init];
    [view addTarget:self action:@selector(onClickStartButton) forControlEvents:UIControlEventTouchUpInside];
    [view setTitle:@"开始抢唱" forState:UIControlStateNormal];
    [self addSubview:view];
    _startButton = view;
  }
  return _startButton;
}

- (void)onClickStartButton {
  if (self.onClickStartGameButton) {
    self.onClickStartGameButton();
  }
}

@end

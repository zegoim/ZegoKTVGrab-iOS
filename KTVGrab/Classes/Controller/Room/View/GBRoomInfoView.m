//
//  ZGKTVUserInfoView.m
//  GoChat
//
//  Created by Vic on 2021/10/22.
//  Copyright © 2021 zego. All rights reserved.
//

#import "GBRoomInfoView.h"
#import "GBImage.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>

@interface GBRoomInfoView ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *subjectLabel;
@property (nonatomic, strong) UILabel *userNameLabel;

@end

@implementation GBRoomInfoView

- (instancetype)init {
  self = [super init];
  if (self) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return self;
}

+ (BOOL)requiresConstraintBasedLayout {
  return YES;
}

- (UIImageView *)avatarImageView {
  if (!_avatarImageView) {
    _avatarImageView = [[UIImageView alloc] init];
    _avatarImageView.layer.cornerRadius = 16;
    _avatarImageView.layer.masksToBounds = YES;
    [self addSubview:_avatarImageView];
  }
  return _avatarImageView;
}

- (UILabel *)subjectLabel {
  if (!_subjectLabel) {
    _subjectLabel = [[UILabel alloc] init];
    _subjectLabel.textColor = [UIColor whiteColor];
    _subjectLabel.font = [UIFont systemFontOfSize:13];
    _subjectLabel.text = @"房间主题 111";
    [self addSubview:_subjectLabel];
  }
  return _subjectLabel;
}

- (UILabel *)userNameLabel {
  if (!_userNameLabel) {
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.textColor = [UIColor whiteColor];
    _userNameLabel.font = [UIFont systemFontOfSize:10];
    _userNameLabel.text = @"姓名 123";
    [self addSubview:_userNameLabel];
  }
  return _userNameLabel;
}

- (void)updateConstraints {
  // Layout
  [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(32, 32));
    make.left.top.bottom.equalTo(self);
  }];
  
  [self.subjectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.avatarImageView).offset(1);
    make.left.equalTo(self.avatarImageView.mas_right).offset(8);
    make.right.equalTo(self);
    make.width.mas_lessThanOrEqualTo(200);
  }];
  
  [self.userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.subjectLabel);
    make.top.equalTo(self.subjectLabel.mas_bottom).offset(2);
  }];
  
  [super updateConstraints];
}

- (void)setRoomName:(NSString *)roomSubject {
  self.subjectLabel.text = roomSubject;
}

- (void)setUser:(GBUser *)user {
  self.avatarImageView.imageURL = [NSURL URLWithString:user.avatarURLString];
  self.userNameLabel.text = user.userName;
}

@end

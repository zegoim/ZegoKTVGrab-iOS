//
//  GBSeatMicOffMask.m
//  KTVGrab
//
//  Created by Vic on 2022/3/25.
//

#import "GBSeatMicOffMask.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import "GBImage.h"

@interface GBSeatMicOffMask ()

@property (nonatomic, strong) UIImageView *micOffImageView;

@end

@implementation GBSeatMicOffMask

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
  
  [self setupSubviews];
}

- (void)setupSubviews {
  [self addSubview:self.micOffImageView];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  self.layer.cornerRadius = 0.5 * CGRectGetWidth(self.bounds);
  self.layer.masksToBounds = YES;
}

- (void)updateConstraints {
  [self.micOffImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self);
    make.size.mas_equalTo(CGSizeMake(24, 28));
  }];
  [super updateConstraints];
}

- (UIImageView *)micOffImageView {
  if (!_micOffImageView) {
    UIImageView *view = [[UIImageView alloc] init];
    view.image = [GBImage imageNamed:@"ktv_seat_mic_close"];
    view.contentMode = UIViewContentModeScaleAspectFit;
    _micOffImageView = view;
  }
  return _micOffImageView;
}

@end

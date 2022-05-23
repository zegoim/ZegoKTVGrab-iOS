//
//  GBChallengeResultBoard.m
//  KTVGrab
//
//  Created by Vic on 2022/2/24.
//

#import "GBChallengeResultBoard.h"
#import "GBImage.h"
#import <Masonry/Masonry.h>

@interface GBChallengeResultBoard ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@end


@implementation GBChallengeResultBoard

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  [self setupSubviews];
}

- (void)setupSubviews {
  [self addSubview:self.imageView];
  [self addSubview:self.label];
}

- (void)setChallengeResult:(BOOL)success {
  NSString *imageName = ({
    NSString *name;
    if (success) {
      name = @"gb_info_board_challenge_success";
    }else {
      name = @"gb_info_board_challenge_failed";
    }
    name;
  });
  UIImage *image = [GBImage imageNamed:imageName];
  self.imageView.image = image;
}

- (void)setChallengeScore:(NSInteger)score {
  self.label.text = [NSString stringWithFormat:@"%ld", (long)score];
}

- (void)layoutSubviews {
  [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];
  
  [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self);
    make.centerY.equalTo(self).offset(-5);
  }];
}

- (UIImageView *)imageView {
  if (!_imageView) {
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
  }
  return _imageView;
}

- (UILabel *)label {
  if (!_label) {
    _label = [[UILabel alloc] init];
    _label.font = [UIFont fontWithName:@"Poppins-SemiBold" size:40];
    _label.textColor = [UIColor whiteColor];
    [self addSubview:_label];
  }
  return _label;
}

@end

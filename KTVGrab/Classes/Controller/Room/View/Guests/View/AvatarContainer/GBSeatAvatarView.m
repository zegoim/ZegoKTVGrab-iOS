//
//  GBSeatAvatarView.m
//  KTVGrab
//
//  Created by Vic on 2022/4/11.
//

#import "GBSeatAvatarView.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>

@interface GBSeatAvatarView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation GBSeatAvatarView

- (void)layoutSubviews {
  [super layoutSubviews];
  self.imageView.layer.cornerRadius = 0.5 * CGRectGetWidth(self.bounds);
  self.imageView.layer.masksToBounds = YES;
}

- (void)updateConstraints {
  [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];
  [super updateConstraints];
}

- (void)setAvatarURLString:(NSString *)urlString {
  [self.imageView setImageURL:[NSURL URLWithString:urlString]];
}

- (UIImageView *)imageView {
  if (!_imageView) {
    _imageView = [[UIImageView alloc] init];
    [self addSubview:_imageView];
  }
  return _imageView;
}

@end

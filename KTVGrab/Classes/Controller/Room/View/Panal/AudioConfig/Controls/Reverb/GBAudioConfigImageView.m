//
//  GBAudioConfigImageView.m
//  KTVGrab
//
//  Created by Vic on 2022/4/14.
//

#import "GBAudioConfigImageView.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "GBImage.h"
#import "GBAudioReverbOverlay.h"

@interface GBAudioConfigImageView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) GBAudioReverbOverlay *overlay;

@end

@implementation GBAudioConfigImageView

- (instancetype)init
{
  self = [super init];
  if (self) {
    [self addSubview:self.imageView];
    [self addSubview:self.overlay];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];
  
  [self.overlay mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];
  
  self.overlay.hidden = !self.selected;
}

- (void)setSelected:(BOOL)selected {
  _selected = selected;
  [self setNeedsLayout];
}

- (void)setImageName:(NSString *)imageName {
  self.imageView.image = [GBImage imageNamed:imageName];
}

- (UIImageView *)imageView {
  if (!_imageView) {
    UIImageView *view = [[UIImageView alloc] init];
    view.contentMode = UIViewContentModeScaleAspectFit;
    _imageView = view;
  }
  return _imageView;
}

- (GBAudioReverbOverlay *)overlay {
  if (!_overlay) {
    _overlay = [[GBAudioReverbOverlay alloc] init];
  }
  return _overlay;
}

@end

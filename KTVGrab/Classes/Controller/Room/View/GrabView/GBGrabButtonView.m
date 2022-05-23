//
//  GBGrabButton.m
//  KTVGrab
//
//  Created by Vic on 2022/3/24.
//

#import "GBGrabButtonView.h"
#import "GBGrabButtonContent.h"
#import "GBRipplesLayer.h"
#import "GBCountdownRingView.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>

/// 抢唱开始前倒计时总时长
static CGFloat const kGBBeforeGrabDuration = 3;
/// 抢唱开始前倒计时 timer 的 interval
static CGFloat const kGBBeforeGrabTimerInterval = 1;
/// 抢唱按钮可以点击的总时长
static CGFloat const kGBGrabbingDuration = 3;
/// 抢唱按钮内容 UI 的边长
static CGFloat const kGBGrabButtonContentEdgeLength = 68;
/// 抢唱开始前的剩余时间, 用于展示 3.2.1 倒计时文本
static CGFloat timeBeforeGrab = kGBBeforeGrabDuration;


@interface GBGrabButtonView ()

/// 3.2.1 倒计时
@property (nonatomic, strong) YYTimer *beforeGrabTimer;

/// 抢麦倒计时
@property (nonatomic, strong) YYTimer *grabbingTimer;

/// 抢麦按钮内容
@property (nonatomic, strong) GBGrabButtonContent *buttonContent;

/// 涟漪动画 layer
@property (nonatomic, strong) GBRipplesLayer *ripplesLayer;

/// 倒计时白色圆圈视图
@property (nonatomic, strong) GBCountdownRingView *ringView;

/// 静态圆环 layer
@property (nonatomic, strong) CAShapeLayer *staticRingLayer;

@end


/*
 1. 在 3.2.1 倒计时的时候, 关闭交互.
 2. 倒计时完毕开启交互.
 3. 点击后, 关闭交互
 */

@implementation GBGrabButtonView

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
  [self addSubview:self.ringView];
  [self.layer addSublayer:self.ripplesLayer];
  [self addSubview:self.buttonContent];
  [self.layer addSublayer:self.staticRingLayer];
}

- (void)layoutSubviews {
  self.ripplesLayer.position = CGPointMake(0.5 * CGRectGetWidth(self.bounds), 0.5 * CGRectGetHeight(self.bounds));
  
  UIBezierPath *staticRingPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width * 0.5,
                                                                                    self.frame.size.height* 0.5)
                                                                 radius:kGBGrabButtonContentEdgeLength / 2
                                                             startAngle:-M_PI_2
                                                               endAngle:M_PI * 3 / 2
                                                              clockwise:1];
  
  self.staticRingLayer.path = staticRingPath.CGPath;
}

- (void)updateConstraints {
  [self.buttonContent mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self);
    make.width.height.mas_equalTo(kGBGrabButtonContentEdgeLength);
  }];
  
  [self.ringView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self);
    make.width.height.mas_equalTo(kGBGrabButtonContentEdgeLength + 12);
  }];
  
  self.buttonContent.layer.cornerRadius = 0.5 * kGBGrabButtonContentEdgeLength;
  self.buttonContent.layer.masksToBounds = YES;
  
  [super updateConstraints];
}

- (GBGrabButtonContent *)buttonContent {
  if (!_buttonContent) {
    _buttonContent = [[GBGrabButtonContent alloc] init];
    [_buttonContent setNumber:timeBeforeGrab];
    @weakify(self);
    _buttonContent.onTouch = ^{
      @strongify(self);
      [self onUserGrab];
    };
  }
  return _buttonContent;
}

- (GBRipplesLayer *)ripplesLayer {
  if (!_ripplesLayer) {
    GBRipplesLayer *layer = [[GBRipplesLayer alloc] init];
    layer.cornerRadius = 52;
    layer.rippleBorderColor = UIColorHex(#FFF0E1);
    _ripplesLayer = layer;
  }
  return _ripplesLayer;
}

- (GBCountdownRingView *)ringView {
  if (!_ringView) {
    _ringView = [[GBCountdownRingView alloc] init];
    _ringView.lineWidth = 2.0f;
    _ringView.duration = kGBGrabbingDuration;
    _ringView.lineColor = UIColorHex(#FFF0E1);
    _ringView.hidden = YES;
    @weakify(self);
    _ringView.onCountdownRingFinished = ^{
      @strongify(self);
      [self onGrabbingCountdownFinished];
    };
  }
  return _ringView;
}

- (CAShapeLayer *)staticRingLayer {
  if (!_staticRingLayer) {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = 1.5;
    layer.strokeColor = [UIColorHex(#FFF0E1) CGColor];
    _staticRingLayer = layer;
  }
  return _staticRingLayer;
}

#pragma mark - Public
- (void)start {
  [self startBeforeGrabTimer];
}

- (void)setGrabDuration:(CGFloat)duration {
  [self.ringView setDuration:duration];
}

#pragma mark - 3.2.1 Timer
- (void)startBeforeGrabTimer {
  if (_beforeGrabTimer) {
    return;
  }
  [self.beforeGrabTimer fire];
}

- (void)invalidateCountingDown {
  if (!_beforeGrabTimer) {
    return;
  }
  [self.beforeGrabTimer invalidate];
  self.beforeGrabTimer = nil;
}

- (YYTimer *)beforeGrabTimer {
  if (!_beforeGrabTimer) {
    _beforeGrabTimer = [YYTimer timerWithTimeInterval:kGBBeforeGrabTimerInterval target:self selector:@selector(countingDown) repeats:YES];
  }
  return _beforeGrabTimer;
}

- (void)countingDown {
  if (timeBeforeGrab == kGBBeforeGrabDuration) {
    // 第一次
    [self onBeforeGrabCountdownStart];
  }
  
  if (timeBeforeGrab > 0) {
    [self onBeforeGrabCountdownProcessing];
  }else {
    [self onBeforeGrabCountdownFinished];
  }
}


#pragma mark - Event
/// 抢唱前倒计时开始
- (void)onBeforeGrabCountdownStart {
  self.staticRingLayer.hidden = NO;
  self.buttonContent.userInteractionEnabled = NO;
  [self.ripplesLayer startAnimation];
  self.buttonContent.grabState = 0;
}

/// 抢唱前倒计时进行中的触发事件
- (void)onBeforeGrabCountdownProcessing {
  [self.buttonContent setNumber:timeBeforeGrab];
  timeBeforeGrab -= kGBBeforeGrabTimerInterval;
}

/// 抢唱前倒计时完毕
- (void)onBeforeGrabCountdownFinished {
  self.staticRingLayer.hidden = YES;
  [self invalidateCountingDown];
  [self.ringView start];
  [self.ripplesLayer removeFromSuperlayer];
  self.ripplesLayer = nil;
  self.buttonContent.grabState = 1;
  self.buttonContent.userInteractionEnabled = YES;
  self.ringView.hidden = NO;
  timeBeforeGrab = kGBBeforeGrabDuration;
}

/// 抢唱没有被点击, 即超时事件
- (void)onGrabbingCountdownFinished {
  self.onGrabbingTimeout();
  NSLog(@"[GB_DEBUG_GRAB_TIMER] Grab time out");
}

/// 触发抢唱
- (void)onUserGrab {
  self.buttonContent.userInteractionEnabled = NO;
  [self.ringView stop];
  self.onClick();
}

@end

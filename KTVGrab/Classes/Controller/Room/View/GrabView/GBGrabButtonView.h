//
//  GBGrabButton.h
//  KTVGrab
//
//  Created by Vic on 2022/3/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBGrabButtonView : UIView

@property (nonatomic, strong) void(^onClick)(void);

@property (nonatomic, strong) void(^onGrabbingTimeout)(void);

- (void)setGrabDuration:(CGFloat)duration;

- (void)start;

@end

NS_ASSUME_NONNULL_END

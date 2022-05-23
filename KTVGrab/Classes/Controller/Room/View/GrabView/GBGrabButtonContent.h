//
//  GBGrabButtonContent.h
//  KTVGrab
//
//  Created by Vic on 2022/3/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBGrabButtonContent : UIView

/// 0-无法抢唱, 1-开始抢唱
@property (nonatomic, assign) NSUInteger grabState;

@property (nonatomic, strong) void(^onTouch)(void);

- (void)setNumber:(int)number;

@end

NS_ASSUME_NONNULL_END

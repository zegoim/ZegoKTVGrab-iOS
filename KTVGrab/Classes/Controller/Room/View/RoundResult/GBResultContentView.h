//
//  GBResultContentView.h
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import <UIKit/UIKit.h>

@class GBUser;
@class GBRoundGrade;

NS_ASSUME_NONNULL_BEGIN

/// No intrinsic width, has intrinsic height
@interface GBResultContentView : UIView

/// 用户
@property (nonatomic, strong) GBUser *user;

/// 战绩
@property (nonatomic, strong) GBRoundGrade *grade;

@property (nonatomic, assign) BOOL spectatorMode;

- (void)setText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END

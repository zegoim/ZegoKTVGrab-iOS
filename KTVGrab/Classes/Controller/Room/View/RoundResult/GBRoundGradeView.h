//
//  GBRoundGradeView.h
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import <UIKit/UIKit.h>

@class GBRoundGrade;

NS_ASSUME_NONNULL_BEGIN

/// No intrinsic size
@interface GBRoundGradeView : UIView

/// 战绩
@property (nonatomic, strong) GBRoundGrade *grade;

@end

NS_ASSUME_NONNULL_END

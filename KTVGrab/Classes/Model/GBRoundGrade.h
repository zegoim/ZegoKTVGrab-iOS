//
//  GBRoundGrade.h
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 一轮游戏的结果数据
 */
@interface GBRoundGrade : NSObject

/**
 * 抢唱数
 */
@property (nonatomic, assign) NSUInteger grabCount;

/**
 * 抢唱及格数
 */
@property (nonatomic, assign) NSUInteger passCount;

/**
 * 一轮下来的总分
 */
@property (nonatomic, assign) NSUInteger score;

@end

NS_ASSUME_NONNULL_END

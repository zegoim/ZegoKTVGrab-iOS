//
//  GBUserAccount.h
//  KTVGrab
//
//  Created by Vic on 2022/4/21.
//

#import <Foundation/Foundation.h>
#import "GBUser.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 可全局获取的本端用户信息
 */
@interface GBUserAccount : NSObject

/**
 * 自己的用户信息
 */
@property (nonatomic, strong, nullable) GBUser *myself;

/**
 * 单例对象
 */
+ (instancetype)shared;

/**
 * 便利方法. 可获取自己的用户权限
 */
- (GBUserAuthority *)getMyAuthority;

@end

NS_ASSUME_NONNULL_END

//
//  GBUserRole.h
//  KTVGrab
//
//  Created by Vic on 2022/4/21.
//

#import <Foundation/Foundation.h>
#import "GBEnums.h"
#import "GBUserAuthority.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBUserRole : NSObject

/**
 * 角色类型
 */
@property (nonatomic, assign) GBUserRoleType roleType;

/**
 * 角色权限
 */
@property (nonatomic, strong, readonly) GBUserAuthority *authority;

/**
 * 根据角色进行初始化
 */
- (instancetype)initWithRoleType:(GBUserRoleType)roleType;

@end

NS_ASSUME_NONNULL_END

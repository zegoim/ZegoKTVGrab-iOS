//
//  GBFoundationService.h
//  KTVGrab
//
//  Created by Vic on 2022/3/7.
//

#import <Foundation/Foundation.h>
#import "GBTypeDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBzSDKLoader : NSObject

/**
 * 加载抢唱模块需要的 SDK 及服务
 */
- (void)loadZegoSDKsWithCompletion:(GBErrorBlock)completion;

/**
 * 卸载抢唱模块需要的 SDK 及服务
 */
- (void)unloadZegoSDKsWithCompletion:(GBEmptyBlock)completion;

@end

NS_ASSUME_NONNULL_END

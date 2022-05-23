//
//  GBFoundationService.m
//  KTVGrab
//
//  Created by Vic on 2022/3/7.
//

#import "GBzSDKLoader.h"
#import "GBIM.h"
#import "GBExpress.h"
#import "GBExternalDependency.h"
#import "GBTokenService.h"
#import <YYKit/YYKit.h>

@implementation GBzSDKLoader

#pragma mark -
#pragma mark - Public
- (void)loadZegoSDKsWithCompletion:(GBErrorBlock)completion {
  GB_LOG_D(@"[SDK_LOADER] Loading Zego SDKs...");
  [self setupExpress];
  [self setupIMWithCompletion:^(NSError *error) {
    if (error) {
      GB_LOG_E(@"[SDK_LOADER] Loading Zego SDKs completes with Error: %@", error);
    }else {
      GB_LOG_D(@"[SDK_LOADER] Loading Zego SDKs completes");
    }
    !completion ?: completion(error);
  }];
}

- (void)unloadZegoSDKsWithCompletion:(GBEmptyBlock)completion {
  GB_LOG_D(@"[SDK_LOADER] Unloading Zego SDKs...");
  [[GBIM shared] destroy];
  [[GBExpress shared] destroy:^{
    GB_LOG_D(@"[SDK_LOADER] Unloading Zego SDKs completes");
  }];
  !completion ?: completion();
}

#pragma mark -
#pragma mark - Private
- (void)setupExpress {
  // 版权音乐的初始化需要在登录房间之后才能进行, rtc 携带 token 登录房间必须让版权服务在登录房间后才能进行
  [[GBExpress shared] create];
  [[GBExpress shared] createMediaPlayer];
}

- (void)setupIMWithCompletion:(GBErrorBlock)completion {
  [[GBIM shared] create];
  [[GBIM shared] loginWithComplete:^(NSError *error) {
    !completion ?: completion(error);
  }];  
}

@end

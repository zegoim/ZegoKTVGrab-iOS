//
//  GBBaseAuthRequest.m
//  KTVGrab
//
//  Created by Vic on 2022/3/12.
//

#import "GBBaseAuthRequest.h"
#import "GBExternalDependency.h"
#import "GBTokenService.h"

@implementation GBBaseAuthRequest

- (NSDictionary *)payload {
  return nil;
}

- (NSDictionary *)parameters {
  GBExternalDependency *deps = [GBExternalDependency shared];
  [deps validate];
  
  NSString *token = [[GBTokenService shared] getCacheToken];
  
  return @{
    @"auth": @{
        @"app_id": @(deps.appID),
        @"uid": deps.userID ?: @"",
        @"token": token ?: @"",
    },
    @"data":[self payload],
  };
}

@end

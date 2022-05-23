//
//  GBSDKModel.m
//  KTVGrab
//
//  Created by Vic on 2022/3/21.
//

#import "GBSDKModel.h"

@implementation GBSDKModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
  return @{
    @"requestID": @"request_id",
  };
}

@end

@implementation GBSDKSongResource

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
  return @{
    @"resourceID": @"resource_id",
    @"token": @"share_token",
  };
}

@end

@implementation GBSDKSongClip

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
  return @{
    @"songID": @"song_id",
    @"krcToken": @"krc_token",
    @"segBegin": @"segment_begin",
    @"segEnd": @"segment_end",
    @"preDuration": @"prelude_duration",
    @"resources": @"resources",
  };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
  return @{
    @"resources": GBSDKSongResource.class,
  };
}

@end

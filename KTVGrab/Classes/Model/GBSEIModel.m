//
//  GBSEIModel.m
//  KTVGrab
//
//  Created by Vic on 2022/3/31.
//

#import "GBSEIModel.h"
#import <YYKit/YYKit.h>

@implementation GBSEIModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
  return @{
    @"role": @"role",
    @"songID": @"id",
    @"playerState": @"state",
    @"progress": @"progress",
    @"duration": @"duration",
  };
}


@end

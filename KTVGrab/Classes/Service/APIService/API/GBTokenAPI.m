//
//  GBTokenAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/3/11.
//

#import "GBTokenAPI.h"

@implementation GBTokenAPI

- (NSString *)path {
  return @"get_token_04";
}

- (NSDictionary *)parameters {
  return @{
    @"uid": [self uid],
  };
}

@end

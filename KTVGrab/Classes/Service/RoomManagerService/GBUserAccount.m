//
//  GBUserAccount.m
//  KTVGrab
//
//  Created by Vic on 2022/4/21.
//

#import "GBUserAccount.h"

@implementation GBUserAccount

+ (instancetype)shared {
  static dispatch_once_t onceToken;
  static id _instance;
  dispatch_once(&onceToken, ^{
    _instance = [[self alloc] init];
  });
  return _instance;
}

- (GBUserAuthority *)getMyAuthority {
  return self.myself.role.authority;
}

@end

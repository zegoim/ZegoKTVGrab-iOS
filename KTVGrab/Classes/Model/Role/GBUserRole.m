//
//  GBUserRole.m
//  KTVGrab
//
//  Created by Vic on 2022/4/21.
//

#import "GBUserRole.h"

@interface GBUserRole ()

@property (nonatomic, strong) GBUserAuthority *authority;

@end

@implementation GBUserRole

- (instancetype)initWithRoleType:(GBUserRoleType)roleType {
  if (self = [super init]) {
    [self setRoleType:roleType];
  }
  return self;
}

- (void)setRoleType:(GBUserRoleType)roleType {
  if (_roleType == roleType) {
    return;
  }
  _roleType = roleType;
  GBUserAuthority *auth = [[GBUserAuthority alloc] initWithRoleType:roleType];
  [self setAuthority:auth];
}

@end

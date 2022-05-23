//
//  GBUserRoleAuthority.m
//  KTVGrab
//
//  Created by Vic on 2022/4/21.
//

#import "GBUserAuthority.h"
#import "GBUserSpectatorAuthority.h"
#import "GBUserPlayerAuthority.h"

@implementation GBUserAuthority

- (instancetype)initWithRoleType:(GBUserRoleType)roleType {
  switch (roleType) {
    case GBUserRoleTypeUnknown:
    case GBUserRoleTypeSpectator:
      return [[GBUserSpectatorAuthority alloc] init];
    case GBUserRoleTypePlayer:
    case GBUserRoleTypeHost:
      return [[GBUserPlayerAuthority alloc] init];
  }
}

@end

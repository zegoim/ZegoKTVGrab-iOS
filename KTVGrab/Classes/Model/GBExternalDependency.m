//
//  GBFoundationModel.m
//  KTVGrab
//
//  Created by Vic on 2022/3/11.
//

#import "GBExternalDependency.h"

@implementation GBExternalDependency

+ (instancetype)shared {
  static dispatch_once_t onceToken;
  static id _instance;
  dispatch_once(&onceToken, ^{
    _instance = [[self alloc] init];
  });
  return _instance;
}

- (void)validate {
  BOOL ret = YES;
  if (self.appID == 0) {
    ret = NO;
  }
  if (!(self.userID.length > 0)) {
    ret = NO;
  }
  if (!(self.hostUrlString.length > 0)) {
    ret = NO;
  }
  
  if (!ret) {
    NSString *reason = [NSString stringWithFormat:@"Invalid GBExternalDependency object: %@", self];
    NSException *exc = [NSException exceptionWithName:NSCocoaErrorDomain reason:reason userInfo:nil];
    [exc raise];
  }
}

- (NSString *)debugDescription {
  return [NSString stringWithFormat:@"GBExternalDependency object, appID: %u, userID: %@, userName: %@, hostURLString: %@", _appID, _userID, _userName, _hostUrlString];
}

@end

//
//  GBTokenService.m
//  KTVGrab
//
//  Created by Vic on 2022/3/11.
//

#import "GBTokenService.h"
#import "GBDataProvider.h"
#import <YYKit/YYKit.h>

@interface GBTokenService ()

@property (nonatomic, copy) NSString *token;

@end

@implementation GBTokenService

+ (instancetype)shared {
  static dispatch_once_t onceToken;
  static id _instance;
  dispatch_once(&onceToken, ^{
    _instance = [[self alloc] init];
  });
  return _instance;
}

- (void)getTokenWithCompletion:(void (^)(NSString * _Nullable))completion shouldForceUpdate:(BOOL)forceUpdate {
  if (!forceUpdate) {
    if (self.token.length > 0) {
      !completion ?: completion(self.token);
      return;
    }
  }
  @weakify(self);
  GB_LOG_D(@"[TOKEN] Get token");
  [GBDataProvider getTokenComplete:^(BOOL suc, NSError * _Nullable err, NSString * _Nullable token) {
    @strongify(self);
    GB_LOG_D(@"[TOKEN] Get token complete: %@", token);
    self.token = token;
    !completion ?: completion(token);
  }];
}

- (NSString *)getCacheToken {
  return self.token;
}

- (void)updateToken:(NSString *)token {
  self.token = token;
}

@end

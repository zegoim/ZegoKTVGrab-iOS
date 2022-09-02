//
//  GBTokenService.m
//  KTVGrab
//
//  Created by Vic on 2022/3/11.
//

#import "GBTokenService.h"
#import "GBDataProvider.h"
#import <YYKit/YYKit.h>

#define GB_TOKEN_DEFAULT_REQ_INTERVAL 5

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

- (void)stop {
  GB_LOG_D(@"[token]Stop requesting token");
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestToken:) object:nil];
}

- (void)requestToken:(void(^)(NSString *token))complete {
  GB_LOG_D(@"[token]Requesting token");
  @weakify(self);
  [GBDataProvider getTokenComplete:^(BOOL suc, NSError * _Nullable err, NSDictionary * _Nonnull data) {
    @strongify(self);
    NSString *token = data[@"token"];
    int tokenDuration = [data[@"token_duration"] intValue];
    GB_LOG_D(@"[token]Requesting token complete: %@, token duration: %d", token, tokenDuration);
    int timeInterval = GB_TOKEN_DEFAULT_REQ_INTERVAL;
    if (token.length > 0) {
      self.token = token;
      timeInterval = MAX(tokenDuration - 300, GB_TOKEN_DEFAULT_REQ_INTERVAL);
    }
    GB_LOG_D(@"[token]Will request token again after %d seconds...", timeInterval);
    [self performSelector:@selector(requestToken:) withObject:nil afterDelay:timeInterval];
    !complete ?: complete(token);
  }];
}

- (NSString *)getCacheToken {
  return self.token;
}

@end

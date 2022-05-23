//
//  GBBaseRequest.m
//  KTVGrab
//
//  Created by Vic on 2022/3/11.
//

#import "GBBaseRequest.h"
#import "GBExternalDependency.h"

@implementation GBBaseRequest

- (NSString *)path {
  return @"";
}

- (NSString *)baseUrl {
  return [GBExternalDependency shared].hostUrlString;
}

- (NSString *)subPath {
  BOOL testEnv = [GBExternalDependency shared].isTestEnv;
  NSString *prefix = @"/grab_mic/v1/";
  if (testEnv) {
    prefix = [@"/alpha" stringByAppendingString:prefix];
  }
  return [prefix stringByAppendingString:[self path]];
}

- (NSString *)uid {
  return [GBExternalDependency shared].userID;
}

- (NSString *)userName {
  return [GBExternalDependency shared].userName;
}


#pragma mark - Convenience

- (void)gb_startWithCompletionBlock:(GBNetworkCompletionBlock)completionBlock dataHandleBlock:(void (^)(NSDictionary * _Nullable))block {
  [self zego_startWithComplete:^(ZegoNetworkRespModel * _Nullable rsp) {
    if (rsp.resultModel.code == 0) {
      NSDictionary *data = rsp.data;
      block(data);
    }else {
      [self responseExceptionHandleWithRetObject:rsp.resultModel complete:completionBlock];
    }
  } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
    [self responseFailHandleWithError:request.error complete:completionBlock];
  }];
}

#pragma mark - Private
- (void)responseFailHandleWithError:(NSError *)error complete:(void(^)(BOOL success, NSError *error, id result))complete {
  if (complete) {
    complete(NO, error, nil);
  }
}

- (void)responseExceptionHandleWithRetObject:(ZegoNetworkRespResultModel *)retObject complete:(void(^)(BOOL success, NSError *error, id result))complete {
  NSError *error = [NSError errorWithDomain:retObject.message?:@"" code:retObject.code userInfo:nil];
  if (complete) {
    complete(YES, error, nil);
  }
}

@end

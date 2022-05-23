//
//  GBSEIService.m
//  KTVGrab
//
//  Created by Vic on 2022/3/31.
//

#import "GBSEIService.h"
#import "GBExpress.h"
#import "GBSEIModel.h"
#import <YYKit/YYKit.h>

@implementation GBSEIService

- (void)dealloc {
  GB_LOG_D(@"[DEALLOC]GBSEIService dealloc");
}

- (void)sendSEIWithRole:(NSUInteger)role songID:(NSString *)songID playerState:(NSUInteger)playerState progress:(NSUInteger)progress duration:(NSUInteger)duration {
  GBSEIModel *model = [[GBSEIModel alloc] init];
  model.role = role;
  model.songID = songID;
  model.playerState = playerState;
  model.progress = progress;
  model.duration = duration;
  
  [self _sendSEIWithModel:model];
}

- (GBSEIModel *)seiModelWithData:(NSData *)data {
  return [GBSEIModel modelWithJSON:data];
}

- (void)_sendSEIWithModel:(GBSEIModel *)model {
  GB_INTERVAL_EXECUTE(kGBSEISendLogInterval, 5, ^{
    GB_LOG_D(@"[SEI] Send SEI: %@", [model modelToJSONString]);
  })
  NSData *data = [model modelToJSONData];
  [[GBExpress shared] sendSEI:data];
}

@end

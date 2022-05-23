//
//  GBNetQualityModel.m
//  KTVGrab
//
//  Created by Vic on 2022/4/15.
//

#import "GBNetQualityModel.h"

@implementation GBNetQualityModel

- (instancetype)init {
  self = [super init];
  if (self) {
    _kbps = -1;
    _rtt = -1;
    _packetLossRate = -1;
  }
  return self;
}

@end

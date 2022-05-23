//
//  ZGKTVGuestCellVM.m
//  GoChat
//
//  Created by Vic on 2021/10/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import "GBSeatCellVM.h"
#import "GBNetQualityModel.h"

@interface GBSeatCellVM ()

@property (nonatomic, strong) GBNetQualityModel *emptyQualityModel;

@end

@implementation GBSeatCellVM

- (GBNetQualityModel *)emptyQualityModel {
  if (!_emptyQualityModel) {
    _emptyQualityModel = [[GBNetQualityModel alloc] init];;
  }
  return _emptyQualityModel;
}

- (instancetype)initWithIndex:(NSUInteger)index {
  self = [super init];
  if (self) {
    _empty = YES;
    _index = index;
  }
  return self;
}

- (BOOL)showTestData {
  if (self.empty) {
    return NO;
  }
  return _showTestData;
}

- (void)setSeatInfo:(GBSeatInfo *)seatInfo {
  _seatInfo = seatInfo;
}

- (NSString *)displayName {
  if (self.seatInfo) {
    return self.seatInfo.userName;
  }
  return [NSString stringWithFormat:@"%lu号麦", (unsigned long)self.index];
}

- (BOOL)mute {
  if (self.seatInfo) {
    return self.seatInfo.mute;
  }
  return YES;
}

- (CGFloat)soundLevel {
  if (self.seatInfo) {
    if (!self.seatInfo.mute) {
      return self.seatInfo.soundLevel;
    }
  }
  return -1;
}

- (NSString *)avatarURLString {
  if (self.seatInfo) {
    return self.seatInfo.avatarURLString;
  }
  return nil;
}

- (BOOL)empty {
  return self.seatInfo == nil;
}

- (NSUInteger)index {
  if (self.seatInfo) {
    return self.seatInfo.seatIndex;
  }
  return _index;
}

- (GBNetQualityModel *)netQuality {
  if (self.seatInfo.hasStream) {
    return self.seatInfo.netQuality;
  }
  return self.emptyQualityModel;
}

- (GBNetQuality)qualityLevel {
  return self.seatInfo.qualityLevel;
}

@end




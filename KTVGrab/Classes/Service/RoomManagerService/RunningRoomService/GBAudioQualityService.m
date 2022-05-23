//
//  GBAudioQualityService.m
//  KTVGrab
//
//  Created by Vic on 2022/4/21.
//

#import "GBAudioQualityService.h"
#import "GBExpress.h"

@implementation GBAudioQualityService

- (void)setStandardAudioQuality {
  [[GBExpress shared] setMainPublisherStandardQuality];
}

- (void)setHighAudioQuality {
  [[GBExpress shared] setMainPublisherHighQuality];
}

@end

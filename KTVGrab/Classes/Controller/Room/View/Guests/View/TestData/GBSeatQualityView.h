//
//  ZGKTVTestDataView.h
//  GoChat
//
//  Created by Vic on 2021/10/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GBNetQualityModel;

NS_ASSUME_NONNULL_BEGIN

/// No intrinsic size
@interface GBSeatQualityHorizontalView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *value;

- (void)resetValue;

@end

@interface GBSeatQualityView : UIView

- (void)setNetQuality:(GBNetQualityModel *)netQuality;
- (void)resetAllValues;

@end

NS_ASSUME_NONNULL_END

//
//  GBSeatBottomView.h
//  KTVGrab
//
//  Created by Vic on 2022/3/28.
//

#import <UIKit/UIKit.h>
#import "GBEnums.h"

NS_ASSUME_NONNULL_BEGIN

/// Has intrinsic size
@interface GBSeatBottomView : UIView

- (void)setText:(NSString *)text;

- (void)setImage:(UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END

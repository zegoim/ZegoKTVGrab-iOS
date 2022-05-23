//
//  GBPureImageBoard.h
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// No intrinsic size
@interface GBPureImageBoard : UIView

- (void)setImage:(UIImage *)image;

- (void)setImage:(UIImage *)image descText:(NSString * __nullable)text;

@end

NS_ASSUME_NONNULL_END

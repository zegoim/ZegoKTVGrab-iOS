//
//  GBPureTextBoard.h
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// No intrinsic size
@interface GBPureTextBoard : UIView

- (void)setText:(NSString *)text;
- (void)setText:(NSString *)text descText:(NSString * _Nullable)descText;

@end

NS_ASSUME_NONNULL_END

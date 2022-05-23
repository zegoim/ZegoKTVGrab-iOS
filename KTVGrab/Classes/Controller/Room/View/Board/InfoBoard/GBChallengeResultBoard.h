//
//  GBChallengeResultBoard.h
//  KTVGrab
//
//  Created by Vic on 2022/2/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// No intrinsic size
@interface GBChallengeResultBoard : UIView

- (void)setChallengeResult:(BOOL)success;

- (void)setChallengeScore:(NSInteger)score;

@end

NS_ASSUME_NONNULL_END

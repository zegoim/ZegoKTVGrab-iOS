//
//  GBAudioConfigImageView.h
//  KTVGrab
//
//  Created by Vic on 2022/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBAudioConfigImageView : UIView

@property (nonatomic, assign) BOOL selected;

- (void)setImageName:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END

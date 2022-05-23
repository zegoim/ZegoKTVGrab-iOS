//
//  GBImage.h
//  KTVGrab
//
//  Created by Zego on 2019/1/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, GBImagePlace) {
  GBImagePlaceBundle = 0,     //spec中设置resource_bundles(图⽚片在framework的bundle中)工程默认使用这种
  GBImagePlaceFrwk       //spec中设置resources(图⽚片直接在framework中)
};

@interface GBImage : NSObject

+ (UIImage *)imageNamed:(NSString *)name;
+ (UIImage *)imageNamed:(NSString *)name type:(GBImagePlace)type;

@end

NS_ASSUME_NONNULL_END

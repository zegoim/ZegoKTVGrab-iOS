//
//  NSBundle+KTVGrab.h
//  KTVGrab
//
//  Created by 万伟琦 on 2022/1/10.
//

#import "NSBundle+KTVGrab.h"
#import "GBImage.h"

@interface GBBundleStubClass : NSObject

@end

@implementation GBBundleStubClass

@end

#pragma mark - category

@implementation NSBundle (KTVGrab)

+ (NSBundle *)GB_bundle {
  NSBundle *currentBundle = [NSBundle bundleForClass:[GBBundleStubClass class]];
  NSURL *url = [currentBundle URLForResource:kBundleName withExtension:@"bundle"];
  return [self bundleWithURL:url];
}

@end

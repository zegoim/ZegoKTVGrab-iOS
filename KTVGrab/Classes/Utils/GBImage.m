//
//  GBImage.m
//  KTVGrab
//
//  Created by Zego on 2019/1/25.
//

#import "GBImage.h"

static NSString * const kBundleName = @"KTVGrab";

@implementation GBImage

+ (UIImage *)imageNamed:(NSString *)name
{
    return [self imageNamed:name type:GBImagePlaceBundle];
}

+ (UIImage *)imageNamed:(NSString *)name type:(GBImagePlace)type
{
    if (type == GBImagePlaceBundle)
    {
        NSBundle *bundle  = [NSBundle bundleForClass:[GBImage class]];
        NSURL *url = [bundle URLForResource:kBundleName withExtension:@"bundle"];
        NSBundle *resourceBundle = [NSBundle bundleWithURL:url];
        UIImage *image = [UIImage imageNamed:name inBundle:resourceBundle compatibleWithTraitCollection:nil];
        return image;
    }
    else if (type == GBImagePlaceFrwk)
    {
        NSBundle *bundle  = [NSBundle bundleForClass:[GBImage class]];
        NSString *filePath = [bundle pathForResource:name ofType:@"png"];
        return [UIImage imageWithContentsOfFile:filePath];
    }
    return [UIImage imageNamed:name];
}


@end

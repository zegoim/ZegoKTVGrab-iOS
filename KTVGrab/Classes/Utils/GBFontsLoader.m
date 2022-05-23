//
//  GBFontsLoader.m
//  KTVGrab
//
//  Created by Vic on 2022/2/24.
//

#import "GBFontsLoader.h"
#import <CoreText/CoreText.h>
#import "NSBundle+KTVGrab.h"

@implementation GBFontsLoader

void CFSafeRelease(CFTypeRef cf) { // redefine this
  if (cf != NULL) {
    CFRelease(cf);
  }
}

+ (void)loadFonts {
  [self loadFontNamed:@"Poppins-SemiBold"];
}

+ (void)loadFontNamed:(NSString *)fontName {
  NSBundle *bundle = [NSBundle GB_bundle];
  NSURL *fontURL = [bundle URLForResource:fontName withExtension:@"ttf"];
  NSData *inData = [NSData dataWithContentsOfURL:fontURL];
  CFErrorRef error;
  CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
  CGFontRef font = CGFontCreateWithDataProvider(provider);
  if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
    CFStringRef errorDescription = CFErrorCopyDescription(error);
    NSLog(@"Failed to load font: %@", errorDescription);
    CFRelease(errorDescription);
  }
  CFSafeRelease(font);
  CFSafeRelease(provider);
}

@end

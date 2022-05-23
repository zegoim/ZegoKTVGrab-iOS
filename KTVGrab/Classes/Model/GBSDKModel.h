//
//  GBSDKModel.h
//  KTVGrab
//
//  Created by Vic on 2022/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBSDKModel : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic,  copy ) NSString *message;
@property (nonatomic,  copy ) NSString *requestID;
@property (nonatomic,  copy ) NSDictionary *data;

@end

@interface GBSDKSongResource : NSObject

@property (nonatomic,  copy ) NSString *resourceID;
@property (nonatomic,  copy ) NSString *token;

@end

@interface GBSDKSongClip : NSObject

@property (nonatomic,  copy ) NSString *songID;
@property (nonatomic,  copy ) NSString *krcToken;
@property (nonatomic, assign) NSUInteger segBegin;
@property (nonatomic, assign) NSUInteger segEnd;
@property (nonatomic, assign) NSUInteger preDuration;
@property (nonatomic,  copy ) NSArray<GBSDKSongResource *> *resources;

@end

NS_ASSUME_NONNULL_END

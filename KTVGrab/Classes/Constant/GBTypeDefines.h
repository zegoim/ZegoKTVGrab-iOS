//
//  GBTypeDefines.h
//  KTVGrab
//
//  Created by Vic on 2022/3/7.
//

#ifndef GBTypeDefines_h
#define GBTypeDefines_h

typedef void(^GBEmptyBlock)(void);
typedef void(^GBErrorBlock)(NSError *error);
typedef void(^GBErrorCodeBlock)(int errorCode);
typedef void(^GBSongDownloadCallback)(NSError *error, CGFloat progress);

typedef int GBPushCommand;

#endif /* GBTypeDefines_h */

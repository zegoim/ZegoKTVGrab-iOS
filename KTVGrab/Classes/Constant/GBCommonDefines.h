//
//  GBCommonDefines.h
//  Pods
//
//  Created by Vic on 2022/5/6.
//

/**
 * 内部宏定义
 */
#ifndef GBCommonDefines_h
#define GBCommonDefines_h

// Log
#define GB_LOG_D(fmt,...) NSLog((@"[GB_LOG][D]" fmt),##__VA_ARGS__);
#define GB_LOG_W(fmt,...) NSLog((@"[GB_LOG][W]" fmt),##__VA_ARGS__);
#define GB_LOG_E(fmt,...) NSLog((@"[GB_LOG][E]" fmt),##__VA_ARGS__);

/**
 * 间隔多少次执行 block
 * @param name 唯一标识名
 * @param count 间隔 count 次数执行一次代码.
 * @param block 执行内容
 */
#ifndef GB_INTERVAL_EXECUTE
#define GB_INTERVAL_EXECUTE(name, count, block)\
static int name = count;\
if (name-- <= 0) {\
name = count;\
block();\
}
#endif

#endif /* GBCommonDefines_h */

#ifndef __MR_SOCIAL_LOGGING_H__
#define __MR_SOCIAL_LOGGING_H__

#ifndef MR_ENABLE_LOGGING
#define MR_ENABLE_LOGGING 1
#endif

#if defined(DEBUG) && MR_ENABLE_LOGGING
#define MRLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define MRLog(...)
#endif

#endif
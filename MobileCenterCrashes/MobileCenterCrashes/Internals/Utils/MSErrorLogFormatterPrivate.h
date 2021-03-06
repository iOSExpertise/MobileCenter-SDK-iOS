/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import "MSErrorLogFormatter.h"
@class MSPLCrashReportThreadInfo;

#ifndef MSErrorLogFormatterPrivate_h
#define MSErrorLogFormatterPrivate_h

@interface MSErrorLogFormatter ()

/**
 * Remove user information from a path when the crash happened in the simulator.
 * @param path
 * @return
 */
+ (NSString *)anonymizedPathFromPath:(NSString *)path;

+ (MSBinaryImageType)imageTypeForImagePath:(NSString *)imagePath processPath:(NSString *)processPath;

/**
 * Create an id for a crash report. Uses the one generated by PLCrashReporter or generates a new UUID.
 * @param report The crash report.
 * @return an error id as a NSString.
 */
+ (NSString *)errorIdForCrashReport:(MSPLCrashReport *)report;

/**
 * Convenience method to add process information and application path to an error log. For simulator builds, it will
 * anonymize the path and remove user information from it. It was not split into two methods because separating into
 * a method to add the processInfo and one for the applicationPath would mean duplicating logic.
 *
 * @param errorLog The error log object that will be returned.
 * @param crashReport The crash
 * @return
 */
+ (MSAppleErrorLog *)addProcessInfoAndApplicationPathTo:(MSAppleErrorLog *)errorLog
                                         fromCrashReport:(MSPLCrashReport *)crashReport;

/**
 * Convenience method to find the crashed thread in a crash report.
 *
 * @param report The crash report.
 * @return the crashed thread info.
 */
+ (MSPLCrashReportThreadInfo *)findCrashedThreadInReport:(MSPLCrashReport *)report;

@end

#endif /* MSErrorLogFormatterPrivate_h */

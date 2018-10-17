//
//  RCModelTool.m
//  RCModel
//
//  Created by 孙承秀 on 2018/10/17.
//  Thank you for YY
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCModelTool.h"

@implementation RCModelTool
RCEncodingNSType RCClassGetNSType(Class cls) {
    if (!cls) return RCEncodingTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return RCEncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return RCEncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return RCEncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return RCEncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return RCEncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return RCEncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return RCEncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return RCEncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return RCEncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return RCEncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return RCEncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return RCEncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return RCEncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return RCEncodingTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return RCEncodingTypeNSSet;
    return RCEncodingTypeNSUnknown;
}
BOOL RCEncodingTypeIsCNumber(RCEncodingType type) {
    switch (type & RCEncodingTypeMask) {
        case RCEncodingTypeBool:
        case RCEncodingTypeInt8:
        case RCEncodingTypeUInt8:
        case RCEncodingTypeInt16:
        case RCEncodingTypeUInt16:
        case RCEncodingTypeInt32:
        case RCEncodingTypeUInt32:
        case RCEncodingTypeInt64:
        case RCEncodingTypeUInt64:
        case RCEncodingTypeFloat:
        case RCEncodingTypeDouble:
        case RCEncodingTypeLongDouble: return YES;
        default: return NO;
    }
}
@end

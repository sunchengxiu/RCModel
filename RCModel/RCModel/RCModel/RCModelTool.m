//
//  RCModelTool.m
//  RCModel
//
//  Copyed and modified by 孙承秀 on 2018/8/26.
//  Thank you for YY
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/5/9.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//
#import "RCModelTool.h"
#import <OBJC/message.h>
#import "NSObject+RCModel.h"
#import "RCModelProtocol.h"
#define force_inline __inline__ __attribute__((always_inline))
@interface NSObject()
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic;
@end
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
id RCValueForKeyPaths(__unsafe_unretained NSDictionary *dic ,__unsafe_unretained NSArray *keyPaths){
    id value = nil;
    NSUInteger max = keyPaths.count;
    for (NSInteger i = 0 ; i < keyPaths.count; i ++) {
        value = dic[keyPaths[i]];
        if (i + 1 < max) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                dic = value;
            } else {
                return nil;
            }
        }
        
    }
    return value;
}
id RCValueForMutiKeys(__unsafe_unretained NSDictionary *dic ,__unsafe_unretained NSArray *mutiKeys){
    id value = nil;
    for (NSString *key in mutiKeys) {
        if ([key isKindOfClass:[NSString class]]) {
            value = dic[key];
            if (value) {
                break;
            }
        } else if ([key isKindOfClass:[NSArray class]]){
            value = RCValueForKeyPaths(dic, (NSArray *)key);
            if (value) {
                break;
            }
        }
    }
    return value;
}
static force_inline  NSNumber *RCNSNumberCreateFromID(__unsafe_unretained id value){
    static dispatch_once_t onceToken;
    static NSCharacterSet *dot ;
    static NSDictionary *dic ;
    // for example value = @"null"
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{
                @"TRUE":@(YES),
                @"True":@(YES),
                @"true":@(YES),
                @"FALSE":@(NO),
                @"False":@(NO),
                @"false":@(NO),
                @"YES":@(YES),
                @"Yes":@(YES),
                @"yes":@(YES),
                @"NO":@(NO),
                @"No":@(NO),
                @"no":@(NO),
                @"NIL":(id)kCFNull,
                @"Nil":(id)kCFNull,
                @"nil":(id)kCFNull,
                @"NULL":(id)kCFNull,
                @"Null":(id)kCFNull,
                @"null":(id)kCFNull,
                @"(NULL)":(id)kCFNull,
                @"(Null)":(id)kCFNull,
                @"(null)":(id)kCFNull,
                @"<NULL>":(id)kCFNull,
                @"<Null>":(id)kCFNull,
                @"<null>":(id)kCFNull,
                };
    });
    if (!value || value == (id)kCFNull) {
        return nil;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *number = dic[value];
        if (number != nil) {
            if (number == (id)kCFNull) {
                return nil;
            }
            return number;
        }
        // double
        if ([value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *str = ((NSString *)value).UTF8String;
            double d = atof(str);
            if (isnan(d) || isinf(d)) {
                return nil;
            }
            return @(d);
        } else {
            const char *str = ((NSString *)value).UTF8String;
            if (!str) {
                return nil;
            }
            return @(atoll(str));
        }
    }
    return nil;
}
static force_inline NSDate *RCNSDateFromString(__unsafe_unretained NSString *string) {
    typedef NSDate* (^RCNSDateParseBlock)(NSString *string);
#define kParserNum 34 // 日期字符串的最大长度,实际
     // 保存对应长度长度日期字符串解析的Block数组,设置数组内值都为0，使用静态来保存解析成NSDate的Block并且设置对应日期字符串长度
    static RCNSDateParseBlock blocks[kParserNum + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            /*
             2014-01-20  // Google
             */
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"YYYY-MM-dd";
            blocks[10] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
        
        {
            /*
             2014-01-20 12:24:48
             2014-01-20T12:24:48   // Google
             2014-01-20 12:24:48.000
             2014-01-20T12:24:48.000
             */
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"YYYY-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"YYYY-MM-dd HH:mm:ss";
            
            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            formatter3.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter3.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter3.dateFormat = @"YYYY-MM-dd'T'HH:mm:ss.SSS";
            
            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter4.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter4.dateFormat = @"YYYY-MM-dd HH:mm:ss.SSS";
            
            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    return [formatter2 dateFromString:string];
                }
            };
            
            blocks[23] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter3 dateFromString:string];
                } else {
                    return [formatter4 dateFromString:string];
                }
            };
        }
        
        {
            /*
             2014-01-20T12:24:48Z        // Github, Apple
             2014-01-20T12:24:48+0800    // Facebook
             2014-01-20T12:24:48+12:00   // Google
             2014-01-20T12:24:48.000Z
             2014-01-20T12:24:48.000+0800
             2014-01-20T12:24:48.000+12:00
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"YYYY-MM-dd'T'HH:mm:ssZ";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"YYYY-MM-dd'T'HH:mm:ss.SSSZ";
            
            blocks[20] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[24] = ^(NSString *string) { return [formatter dateFromString:string]?: [formatter2 dateFromString:string]; };
            blocks[25] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[28] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
            blocks[29] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
        
        {
            /*
             Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             Fri Sep 04 00:12:21.000 +0800 2015
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z YYYY";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z YYYY";
            
            blocks[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[34] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
    });
    if (!string) return nil;
    if (string.length > kParserNum) return nil;
    RCNSDateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
#undef kParserNum
}
static force_inline  void RCModelSetNumberValueForProperty(__unsafe_unretained id model , __unsafe_unretained NSNumber *number , __unsafe_unretained RCModelPropertyMeta *propertyMeta){
    switch (propertyMeta.encodingType & RCEncodingTypeMask) {
        case RCEncodingTypeBool:
        {
         ((void (*)(id , SEL , bool)) objc_msgSend)((id)(model),propertyMeta.setter,number.boolValue);
        }
            break;
        case RCEncodingTypeInt8:
        {
            ((void (*)(id , SEL , int8_t)) objc_msgSend)((id)(model),propertyMeta.setter,(int8_t)number.charValue);
        }
            break;
        case RCEncodingTypeUInt8:
        {
            ((void (*)(id , SEL , uint8_t)) objc_msgSend)((id)(model),propertyMeta.setter,(uint8_t)number.unsignedCharValue);
        }
            break;
        case RCEncodingTypeInt16:
        {
            ((void (*)(id , SEL , int16_t)) objc_msgSend)((id)(model),propertyMeta.setter,(int16_t)number.shortValue);
        }
            break;
        case RCEncodingTypeUInt16:
        {
            ((void (*)(id , SEL , uint16_t)) objc_msgSend)((id)(model),propertyMeta.setter,(uint16_t)number.unsignedShortValue);
        }
            break;
        case RCEncodingTypeInt32:
        {
            ((void (*)(id , SEL , int32_t)) objc_msgSend)((id)(model),propertyMeta.setter,(int32_t)number.intValue);
        }
            break;
        case RCEncodingTypeUInt32:
        {
            ((void (*)(id , SEL , uint32_t)) objc_msgSend)((id)(model),propertyMeta.setter,(uint32_t)number.unsignedIntValue);
        }
            break;
        case RCEncodingTypeInt64:
        {
            if ([number isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id , SEL , int64_t)) objc_msgSend)((id)model , propertyMeta.setter , (int64_t)number.stringValue.longLongValue);
            } else {
                ((void (*)(id , SEL , int64_t)) objc_msgSend)((id)model , propertyMeta.setter , (uint64_t)number.longLongValue);
            }
        }
            break;
        case RCEncodingTypeUInt64:
        {
            if ([number isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id , SEL , int64_t)) objc_msgSend)((id)model , propertyMeta.setter , (int64_t)number.stringValue.longLongValue);
            } else {
                ((void (*)(id , SEL , int64_t)) objc_msgSend)((id)model , propertyMeta.setter , (uint64_t)number.longLongValue);
            }
        }
            break;
        case RCEncodingTypeFloat:
        {
            float f = number.floatValue;
            if (isnan(f) || isinf(f)) {
                f = 0;
            }
            ((void (*) (id , SEL , float) ) objc_msgSend)((id)model , propertyMeta.setter , f);
        }
            break;
        case RCEncodingTypeDouble:
        {
            double d = number.doubleValue;
            if (isnan(d) || isinf(d)) {
                d = 0;
            }
            ((void (*) (id , SEL , float) ) objc_msgSend)((id)model , propertyMeta.setter , d);
        }
            break;
        case RCEncodingTypeLongDouble:
        {
            long double d = number.doubleValue;
            if (isnan(d) || isinf(d)) {
                d = 0;
            }
            ((void (*) (id , SEL , long double) ) objc_msgSend)((id)model , propertyMeta.setter , (long double)d);
        }
            break;
        default:
            break;
    }
}
static force_inline Class RCNSBlockClass(){
    static dispatch_once_t onceToken;
    static Class cls;
    dispatch_once(&onceToken, ^{
        void (^block)(void)= ^{};
        Class cls = ((NSObject *)block).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
        
    });
    return cls;
}
void RCModelSetValueForProperty(__unsafe_unretained id model , __unsafe_unretained id value , __unsafe_unretained RCModelPropertyMeta *propertyMeta){
    if (propertyMeta.isCNumber) {
        // 将基本数据类型转化为 NSNumber
        NSNumber *number = RCNSNumberCreateFromID(value);
        RCModelSetNumberValueForProperty(model, number, propertyMeta);
        if (number) {
            [number class]; // hold number?
        }
    } else if(propertyMeta.nsType){
        if (value == (id)kCFNull) {
            ((void (*)(id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter , (id)nil);
        } else {
            switch (propertyMeta.nsType) {
                case RCEncodingTypeNSString:
                case RCEncodingTypeNSMutableString:
                {
                    BOOL muti = propertyMeta.nsType == RCEncodingTypeNSMutableString;
                    if ([value isKindOfClass:[NSString class]]) {
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter , (!muti ? (id)value : (id)(((NSString *)value).mutableCopy)));
                    } else if ([value isKindOfClass:[NSNumber class]]){
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter , (!muti ? ((NSNumber *)value).stringValue : ((NSNumber *)value).stringValue.mutableCopy));
                    } else if ([value isKindOfClass:[NSData class]]){
                        NSMutableString *str = [[NSMutableString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter , str);
                    } else if ([value isKindOfClass:[NSURL class]]){
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter , !muti ? (((NSURL *)value).absoluteString) : (((NSURL *)value).absoluteString.mutableCopy));
                    } else if ([value isKindOfClass:[NSAttributedString class]]){
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter , !muti ? (((NSAttributedString *)value).string) : (((NSAttributedString *)value).string.mutableCopy));
                    }
                }
                    break;
                    
                case RCEncodingTypeNSValue:
                case RCEncodingTypeNSNumber:
                case RCEncodingTypeNSDecimalNumber:
                {
                    if (propertyMeta.encodingType == RCEncodingTypeNSNumber) {
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,RCNSNumberCreateFromID(value));
                    } else if(propertyMeta.encodingType == RCEncodingTypeNSDecimalNumber){
                        if ([value isKindOfClass:[NSDecimalNumber class]]){
                            ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,value);
                        } else if ([value isKindOfClass:[NSNumber class]]){
                            NSDecimalNumber *dnumber = [NSDecimalNumber decimalNumberWithDecimal:[(NSNumber *)value decimalValue]];
                            ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,dnumber);
                        } else if ([value isKindOfClass:[NSString class]]){
                            NSDecimalNumber *dnumber = [NSDecimalNumber decimalNumberWithString:value];
                            NSDecimal dec = [dnumber decimalValue];
                            if (dec._length == 0 && dec._isNegative) {
                                dnumber = nil; // NaN
                            }
                            ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,dnumber);
                        }
                    }
                }
                    break;
                case RCEncodingTypeNSData:
                case RCEncodingTypeNSMutableData:
                {
                    BOOL muti = propertyMeta.nsType == RCEncodingTypeNSMutableData;
                    if ([value isKindOfClass:[NSData class]]) {
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,value);
                    } else if ([value isKindOfClass:[NSString class]]){
                        NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,!muti ? data : data.mutableCopy);
                    }
                }
                    break;
                case RCEncodingTypeNSDate:
                {
                    if ([value isKindOfClass:[NSString class]]) {
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,RCNSDateFromString(value));
                    }else if ([value isKindOfClass:[NSDate class]]){
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,value);
                    }
                    
                }
                    break;
                case RCEncodingTypeNSURL:
                {
                    if ([value isKindOfClass:[NSURL class]]) {
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,value);
                    } else if ([value isKindOfClass:[NSString class]]){
                        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                        NSString *str = [value stringByTrimmingCharactersInSet:set];
                        if (str.length == 0 ) {
                            ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,nil);
                        } else {
                            ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,[NSURL URLWithString:str]);
                        }
                    }
                }
                    break;
                case RCEncodingTypeNSArray:
                case RCEncodingTypeNSMutableArray:
                {
                    // 有自定义映射
                    if (propertyMeta.mapperCls) {
                        NSArray *valueArr = nil;
                        if ([value isKindOfClass:[NSSet class]]) {
                            valueArr = [(NSSet *)value allObjects];
                        }  else if ([value isKindOfClass:[NSArray class]]){
                            valueArr = (NSArray *)value;
                        }
                        if (valueArr) {
                            // 如数组里面放的泛型
                            NSMutableArray *objectArr = [NSMutableArray array];
                            for (id object in valueArr) {
                                if ([object isKindOfClass:propertyMeta.mapperCls]) {
                                    [objectArr addObject:object];
                                } else if([object isKindOfClass:[NSDictionary class]]){
                                    Class newClass = propertyMeta.mapperCls;
                                    if (propertyMeta.isHasCustomMapperDictionary) {
                                        newClass = [newClass modelCustomClassForDictionary:object];
                                        if (!newClass) {
                                            newClass = propertyMeta.mapperCls;
                                        }
                                    }
                                    
                                    NSObject *newObject = [newClass new];
                                    // 递归 json -> model
                                    [newObject modelSetWithDictionary:object];
                                    [objectArr addObject:newObject];
                                }
                            }
                            ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,objectArr);
                        }
                    } else {
                        BOOL muti = propertyMeta.nsType == RCEncodingTypeNSMutableArray;
                        if ([value isKindOfClass:[NSArray class]]) {
                            ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,!muti ? value : ((NSArray *)value).mutableCopy);
                        } else if ([value isKindOfClass:[NSSet class]]){
                            ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,!muti ? [((NSSet *)value) allObjects] : ((NSSet *)value).allObjects.mutableCopy);
                        }
                    }
                }
                    break;
                    
                case RCEncodingTypeNSDictionary:
                case RCEncodingTypeNSMutableDictionary:
                {
                    if (propertyMeta.mapperCls) {
                        // 字典里含有多个模型映射
                        NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
                        [((NSDictionary *)value) enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                            if ([obj isKindOfClass:[NSDictionary class]]) {
                                Class newClass = propertyMeta.mapperCls;
                                if (propertyMeta.isHasCustomMapperDictionary) {
                                    // 二次检测，返回一个最适合的类，继续递归魔性转换
                                    newClass = [newClass modelCustomClassForDictionary:obj];
                                    if (newClass == nil) {
                                        newClass = propertyMeta.mapperCls;
                                    }
                                }
                                NSObject *object = [newClass new];
                                [object modelSetWithDictionary:obj];
                                if (obj != nil) {
                                     mdic[key] = obj;
                                }
                            }
                            ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,mdic);
                        }];
                        
                    } else {
                        BOOL muti = propertyMeta.nsType == RCEncodingTypeNSMutableDictionary;
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,!muti ?  value: ((NSDictionary *)value).mutableCopy);
                    }
                }
                    break;
                    
                case RCEncodingTypeNSSet:
                case RCEncodingTypeNSMutableSet:
                {
                    NSSet *set = nil;
                    if ([value isKindOfClass:[NSSet class]]) {
                        set = (NSSet *)value;
                    } else if ([value isKindOfClass:[NSArray class]]){
                        set = [NSMutableSet setWithArray:value];
                    }
                    if (propertyMeta.mapperCls) {
                        if (set != nil) {
                            NSMutableSet *valueSet = [NSMutableSet set] ;
                            for (id obj in set) {
                                if ([set isKindOfClass:propertyMeta.mapperCls ]) {
                                    [valueSet addObject:obj];
                                } else {
                                    if ([obj isKindOfClass:[NSDictionary class]]) {
                                        Class newClass = propertyMeta.mapperCls;
                                        if (propertyMeta.isHasCustomMapperDictionary) {
                                            newClass = [newClass modelCustomClassForDictionary:obj];
                                        }
                                        NSObject *object = [newClass  new];
                                        [object modelSetWithDictionary:obj];
                                        [valueSet addObject:object];
                                    }
                                }
                            }
                            ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,valueSet);
                        }
                    } else {
                        BOOL ismuti = propertyMeta.nsType == RCEncodingTypeNSMutableSet;
                        ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,!ismuti ? set : set.mutableCopy );
                    }
                }
                    break;
                    default:
                    break;
            }
        }
    } else {
        BOOL isNULL = value == (id)kCFNull;
        switch (propertyMeta.encodingType & RCEncodingTypeMask) {
            case RCEncodingTypeObject:
            {
                Class cls = propertyMeta.mapperCls?:propertyMeta.cls;
                if (isNULL) {
                    ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,(id)nil);
                } else if ([value isKindOfClass:cls] || !value){
                    ((void (*) (id , SEL , id))objc_msgSend)((id)model , propertyMeta.setter ,value);
                } else if ([value isKindOfClass:[NSDictionary class]]){
                    NSObject *one = nil;
                    if (propertyMeta.getter) {
                        one = ((id (*) (id , SEL ))objc_msgSend)((id)model , propertyMeta.getter );
                    }
                    if (one) {
                        [one modelSetWithDictionary:value];
                    } else {
                        if (propertyMeta.isHasCustomMapperDictionary) {
                            cls = [cls modelCustomClassForDictionary:value] ?: cls;
                        }
                        one = [cls new];
                        [one modelSetWithDictionary:value];
                        ((void (*) (id , SEL ,id))objc_msgSend)((id)model , propertyMeta.setter , one );
                    }
                }
            }
                break;
            case RCEncodingTypeClass:
            {
                if (isNULL) {
                    ((void (*) (id , SEL ,Class))objc_msgSend)((id)model , propertyMeta.setter , (Class)NULL );

                } else {
                    Class cls = nil;
                    if ([value isKindOfClass:[NSString class]]) {
                        cls = NSClassFromString(value);
                        if (cls) {
                            ((void (*) (id , SEL ,Class))objc_msgSend)((id)model , propertyMeta.setter , cls );

                        }
                    } else {
                        cls = object_getClass(value);
                        if (cls) {
                            if (class_isMetaClass( cls )) {
                                ((void (*) (id , SEL ,Class))objc_msgSend)((id)model , propertyMeta.setter , (Class)value );
                            }
                        }
                    }
                }
            }
                break;
            case RCEncodingTypeSEL:{
                if (isNULL) {
                    ((void (*) (id , SEL ,SEL))objc_msgSend)((id)model , propertyMeta.setter , (SEL)NULL );
                } else {
                    if ([value isKindOfClass:[NSString class]]) {
                        SEL sel = NSSelectorFromString(value);
                        if (sel) {
                            ((void (*) (id , SEL ,SEL))objc_msgSend)((id)model , propertyMeta.setter , (SEL)sel );
                        }
                    } else {
                    
                    }
                }
            }
                break;
            case RCEncodingTypeBlock:{
                if (isNULL) {
                    ((void (*) (id , SEL ,void (^)(void)))objc_msgSend)((id)model , propertyMeta.setter , (void (^)(void))NULL);
                } else if ([value isKindOfClass:RCNSBlockClass()]){
                    ((void (*) (id , SEL ,void (^)(void)))objc_msgSend)((id)model , propertyMeta.setter , (void (^)(void))value);
                }
            }
                break;
                // C 类型 用 NSValue 包装
            case RCEncodingTypeCArray:
            case RCEncodingTypeUnion:
            case RCEncodingTypeStruct:
            {
                if ([value isKindOfClass:[NSValue class]]) {
                    const char *type = ((NSValue *)value).objCType;
                    const char *typeEncoding = propertyMeta.propertyInfo.typeEncoding.UTF8String;
                    if (type && typeEncoding && strcmp(type, typeEncoding) == 0) {
                        // 结构体使用 KVC 赋值
                        [model setValue:(NSValue *)value forKey:propertyMeta.name];
                    }
                }
            }
                break;
                // 指针类型
            case RCEncodingTypeCString:
            case RCEncodingTypePointer:
            {
                if (isNULL) {
                    ((void (*) (id , SEL ,void *))objc_msgSend)((id)model , propertyMeta.setter , (void *)NULL);
                } else if ([value isKindOfClass:[NSValue class]]){
//                    [NSValue valueWithPointer:(nullable const void *)] , 要传入 （void *），需要转化成这个类型，所以类型就是 ^v
                    NSValue *nsvalue = (NSValue *)value;
                    if (nsvalue &&nsvalue.objCType && strcmp(nsvalue.objCType, "^v") == 0) {
                        ((void (*) (id , SEL ,void *))objc_msgSend)((id)model , propertyMeta.setter , nsvalue.pointerValue);
                    }
                }
            }
            default:break;
        }
    }
}
@end

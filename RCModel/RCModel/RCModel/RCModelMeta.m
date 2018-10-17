//
//  RCModelMeta.m
//  RCModel
//
//  Created by 孙承秀 on 2018/10/16.
//  Thank you for YY
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCModelMeta.h"
#import "RCClassInfo.h"
#import "RCModelProtocol.h"
#import "RCModelPropertyMeta.h"
#import <OBJC/runtime.h>
@interface RCModelMeta()
{
    RCClassInfo *_classInfo;
}
@end
@implementation RCModelMeta
- (instancetype)initWithClass:(Class)cls{
    RCClassInfo *classInfo = [RCClassInfo classInfoWithClass:cls];
    if (!classInfo) {
        return nil;
    }
    self = [super init];
    NSSet *blackSet = nil;
    if ([cls respondsToSelector:@selector(modelPropertyBlacklist)]) {
        NSArray *arr = [(id<RCModelProtocol>)cls modelPropertyBlacklist];
        if (arr) {
            blackSet = [NSSet setWithArray:arr];
        }
    }
    NSSet *whiteSet = nil;
    if ([cls respondsToSelector:@selector(modelPropertyWhitelist)]) {
        NSArray *arr = [(id<RCModelProtocol>)cls modelPropertyWhitelist];
        if (arr) {
            whiteSet = [NSSet setWithArray:arr];
        }
    }
    // 自定义映射
    NSDictionary *customMapper;
    if ([cls respondsToSelector:@selector(modelCustomPropertyMapClass)]) {
        customMapper = [(id<RCModelProtocol>)cls modelCustomPropertyMapClass];
        if (customMapper) {
            NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
            [customMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (![key isKindOfClass:[NSString class]]) {
                    NSLog(@"key is not nsstring");
                    return ;
                }
                Class meta = object_getClass(obj);
                if (!meta) {
                    NSLog(@"RCModelMete custom mapper obj is nil");
                    return;
                }
                // RCUser.class
                if (class_isMetaClass(meta)) {
                    tmp[key] = obj;
                } else if([obj isKindOfClass:[NSString class]]){
                    Class class = NSClassFromString(obj);
                    if (class) {
                         tmp[key] = class;
                    }
                }
            }];
            customMapper = tmp.copy;
        }
    }
    NSMutableDictionary *allPropertys = [NSMutableDictionary dictionary];
    RCClassInfo *currentClassInfo = classInfo;
    while (currentClassInfo && currentClassInfo.superCls != nil) {
        for (RCObjc_property *propertyInfo in currentClassInfo.propertyList.allValues) {
            if (!propertyInfo.name) {
                continue;
            }
            if ([blackSet containsObject:propertyInfo.name]) {
                continue;
            }
            if (![whiteSet containsObject:propertyInfo.name]) {
                continue;
            }
            RCModelPropertyMeta *propertyMeta = [RCModelPropertyMeta propertyMetaWithClassInfo:currentClassInfo propertyInfo:propertyInfo mapper:customMapper[propertyInfo.name]];
            if (!propertyMeta.name) {
                continue;
            }
            if (!propertyMeta.setter || !propertyInfo.getter) {
                continue;
            }
            if (allPropertys[propertyMeta.name]) {
                continue;
            }
            allPropertys[propertyMeta.name] = propertyMeta;
        }
    }
    _allPropertyMetaArrs = allPropertys.allValues.copy;
    NSMutableDictionary *keyPaths = [NSMutableDictionary dictionary];
    NSMutableDictionary *mutiKeyPaths = [NSMutableDictionary dictionary];
    
    // 自定义映射
    
    return nil;
}
+ (instancetype)metaWithClass:(Class)cls{
    if (!cls) {
        return nil;
    }
    static dispatch_once_t onceToken;
    static CFMutableDictionaryRef cache;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        cache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    // 做缓存
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    RCModelMeta *meta = CFDictionaryGetValue(cache, (const void *)cls);
    dispatch_semaphore_signal(lock);
    if (!meta || [meta->_classInfo needUpdate]) {
        meta = [[RCModelMeta alloc] initWithClass:cls];
        if (meta) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(cache, (__bridge const void *)cls, (__bridge const void *)meta);
            dispatch_semaphore_signal(lock);
        }
    }
    return meta;
}
@end

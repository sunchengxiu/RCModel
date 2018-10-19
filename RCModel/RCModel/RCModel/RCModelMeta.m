//
//  RCModelMeta.m
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

#import "RCModelMeta.h"
#import "RCClassInfo.h"
#import "RCModelProtocol.h"
#import "RCModelPropertyMeta.h"
#import "RCModelTool.h"
#import <OBJC/runtime.h>
@interface RCModelMeta()
{
    RCClassInfo *_classInfo;
    RCEncodingNSType _nsType;
    NSMutableArray *_keyPathsArr;
    NSMutableArray *_mutiKeyPathArr;
    NSMutableDictionary *_mapper;
}

/**
 所有的 propertyMeta 信息
 */
@property(nonatomic , copy )NSArray *allPropertyMetaArrs;

/**
 自定义属性映射
 */
@property(nonatomic , assign )BOOL isCustomClassFromDictionary;

/**
 映射数量
 */
@property(nonatomic , assign )NSUInteger keyMapCount;
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
    NSMutableDictionary *mapper = [NSMutableDictionary dictionary];
    NSMutableArray *keyPaths = [NSMutableArray array];
    NSMutableArray *mutiKeyPaths = [NSMutableArray array];
    
    // 自定义键值对映射
    if ([cls respondsToSelector:@selector(modelCustomPropertyMapper)]) {
        NSDictionary *customMapper = [(id<RCModelProtocol>)cls modelCustomPropertyMapper];
        [customMapper enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull propertyName, NSString *  _Nonnull map, BOOL * _Nonnull stop) {
            // 去掉特殊映射
            RCModelPropertyMeta *propertyMeta = allPropertys[propertyName];
            if (propertyMeta != nil) {
                [allPropertys removeObjectForKey:propertyName];
            }
            // 简单键值对映射
            if ([map isKindOfClass:[NSString class]]) {
                if (map.length == 0 ) {
                    return ;
                }
                propertyMeta.mapToKey = map;
                // keypath 键值对映射
                NSArray *keyPath = [map componentsSeparatedByString:@"."];
                for (NSString *value in keyPath) {
                    if (value.length == 0) {
                        NSMutableArray *values = keyPath.mutableCopy;
                        [values removeObject:@""];
                        keyPath = values.copy;
                        break;
                    }
                }
                if (keyPath.count > 0) {
                    propertyMeta.mapToKeyPath = keyPath;
                    [keyPaths addObject:propertyMeta];
                }
                // 多个属性映射同一个可以
                /*
                 {
                    @"id":@"id",
                    "uid":@"id",
                    "userID":@"id"
                 }
                 */
                propertyMeta.next = mapper[map]?:nil;
                mapper[map] = propertyMeta;
            } else if ([map isKindOfClass:[NSArray class]]){
                NSArray *mapArr = (NSArray *)map;
                NSMutableArray *keyArray = [NSMutableArray array];
                for (NSString *key in mapArr) {
                    if (key == nil) {
                        return;
                    }
                    if (key.length == 0 ) {
                        return;
                    }
                    NSArray *keypaths = [key componentsSeparatedByString:@"."];
                    // @"bookID": @[@"id", @"ext.ID", @"book_id"]}
                    if (keyPaths.count > 0) {
                        [keyArray addObject:keyPaths];
                    } else {
                        [keyArray addObject:key];
                    }
                    if (!propertyMeta.mapToKey) {
                        propertyMeta.mapToKey = key;
                        propertyMeta.mapToKeyPath = keyPaths.count > 0 ? keypaths : nil;
                    }
                }
                if (!propertyMeta.mapToKey) {
                    return;
                }
                propertyMeta.mapToArray = keyArray;
                [mutiKeyPaths addObject:propertyMeta];
                propertyMeta.next = mapper[map]?:nil;
                mapper[map] = propertyMeta;
            }
        }];
    }
    
    // 其余剩下的没有自定义的键值对映射
    [allPropertys enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, RCModelPropertyMeta *  _Nonnull propertyMeta, BOOL * _Nonnull stop) {
        propertyMeta.mapToKey = key;
        propertyMeta.next = mapper[key]?:nil;
        mapper[key] = propertyMeta;
    }];
    if (mapper) {
        _mapper = mapper;
    }
    if (keyPaths) {
        _keyPathsArr = keyPaths;
    }
    if (mutiKeyPaths) {
        _mutiKeyPathArr = mutiKeyPaths;
    }
    _classInfo = classInfo;
    _nsType = RCClassGetNSType(cls);
    _keyMapCount = _allPropertyMetaArrs.count;
    _isCustomClassFromDictionary = [cls respondsToSelector:@selector(modelCustomClassForDictionary:)];
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
//
//  RCModelTool.h
//  RCModel
//
//  Copyed and modified  by 孙承秀 on 2018/8/26.
//  Thank you for YY
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/5/9.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>
#import "RCModelDefine.h"
#import "RCModelPropertyMeta.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCModelTool : NSObject

/**
 获取该类是属于哪个系统 NS 类的

 @param cls 类
 @return NS 类
 */
RCEncodingNSType RCClassGetNSType(Class cls);

/**
 是否是基本数据类型

 @param type 要获取的类型
 @return 是否是基本数据类型
 */
BOOL RCEncodingTypeIsCNumber(RCEncodingType type);

/**
 将复杂键值对解析成对应的 value

 @param dic 元数据字典
 @param mutiKeys 复杂键值对
 @return 解析成功的 value
 */
id RCValueForMutiKeys(__unsafe_unretained NSDictionary *dic , __unsafe_unretained NSArray *mutiKeys);

/**
 将复杂键值对解析成对应的 value
 
 @param dic 元数据字典
 @param keyPaths 复杂键值对
 @return 解析成功的 value
 */
id RCValueForKeyPaths(__unsafe_unretained NSDictionary *dic ,__unsafe_unretained NSArray *keyPaths);

/**
 json -> model 将 property 赋值

 @param model model
 @param value 设置的 value
 @param propertyMeta propertyMeta
 */
void RCModelSetValueForProperty(__unsafe_unretained id model , __unsafe_unretained id value , __unsafe_unretained RCModelPropertyMeta *propertyMeta);
//
///**
// 将 NSNumber 已元基本数据类型形式发送赋值
//
// @param model model
// @param number NSNumber
// @param propertyMeta propertyMeta
// */
//void RCModelSetNumberValueForProperty(__unsafe_unretained id model , __unsafe_unretained NSNumber *number , __unsafe_unretained RCModelPropertyMeta *propertyMeta);
//
///**
// 将 value 转化为 NSNumber
//
// @param value 要转化的 value
// @return 转化后的 NSNumber 或 nil
// */
//NSNumber *RCNSNumberCreateFromID(__unsafe_unretained id value);
@end

NS_ASSUME_NONNULL_END

//
//  RCModelMeta.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCModelMeta : NSObject

/**
 所有的 propertyMeta 信息
 */
@property(nonatomic , copy , readonly)NSArray *allPropertyMetaArrs;

/**
 自定义属性映射
 */
@property(nonatomic , assign , readonly)BOOL isCustomClassFromDictionary;

/**
 映射数量
 */
@property(nonatomic , assign , readonly)NSUInteger keyMapCount;

/**
 初始化 modelMeta 类

 @param cls 当前类
 @return 初始化后的m meta 模型
 */
+ (instancetype)metaWithClass:(Class)cls;
@end

NS_ASSUME_NONNULL_END

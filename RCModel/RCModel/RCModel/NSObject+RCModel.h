//
//  NSObject+RCModel.h
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
#import "RCModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RCModel)
/**
 json -> model
 
 @param dic 要转化的字典
 @return 数据模型
 */
+ (instancetype)modelWithDictionary:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END

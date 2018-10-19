//
//  NSObject+RCModel.m
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
#import "NSObject+RCModel.h"
#import "RCModelMeta.h"
#import "RCModelProtocol.h"
@implementation NSObject (RCModel)

/**
 将字典动态转化为数据模型

 @param dic 要转化的字典
 @return 数据模型
 */
+ (instancetype)modelWithDictionary:(NSDictionary *)dic{
    if (dic == nil || [dic isKindOfClass:[NSNull class]] || [dic isEqual:[NSNull null]] || dic == (id)kCFNull) {
        NSLog(@"dic is not enable nil");
        return nil;
    }
    if (![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"dic is not NSDictionary class");
        return nil;
    }
    Class cls = [self class];
    RCModelMeta *modelMeta = [RCModelMeta metaWithClass:cls];
    if (modelMeta.isCustomClassFromDictionary) {
        cls = [(id<RCModelProtocol>)cls modelCustomClassForDictionary:dic];
    }
    
    return nil;
}
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic{
    return YES;
}
@end



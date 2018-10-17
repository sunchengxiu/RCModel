//
//  NSObject+RCModel.m
//  RCModel
//
//  Created by 孙承秀 on 2018/8/26.
//  Thank you for YY
//  Copyright © 2018 RongCloud. All rights reserved.
//

#import "NSObject+RCModel.h"
#import "RCModelMeta.h"
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
    return nil;
}
@end



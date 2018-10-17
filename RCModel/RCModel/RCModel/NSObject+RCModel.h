//
//  NSObject+RCModel.h
//  RCModel
//
//  Created by 孙承秀 on 2018/8/26.
//  Copyright © 2018 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RCModel)
/**
 将字典动态转化为数据模型
 
 @param dic 要转化的字典
 @return 数据模型
 */
+ (instancetype)modelWithDictionary:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END

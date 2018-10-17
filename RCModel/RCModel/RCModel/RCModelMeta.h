//
//  RCModelMeta.h
//  RCModel
//
//  Created by 孙承秀 on 2018/10/16.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCModelMeta : NSObject

/**
 所有的 propertyMeta 信息
 */
@property(nonatomic , copy)NSArray *allPropertyMetaArrs;
@end

NS_ASSUME_NONNULL_END

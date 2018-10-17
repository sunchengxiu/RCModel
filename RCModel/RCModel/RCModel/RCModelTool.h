//
//  RCModelTool.h
//  RCModel
//
//  Created by 孙承秀 on 2018/10/17.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCModelDefine.h"
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
@end

NS_ASSUME_NONNULL_END

//
//  NSDictionary+add.h
//  RCModel
//
//  Created by 孙承秀 on 2018/10/23.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (add)
- (int)intValueForKey:(NSString *)key default:(int)def;
@end

NS_ASSUME_NONNULL_END

//
//  person.h
//  RCModel
//
//  Created by 孙承秀 on 2018/8/29.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "son.h"
NS_ASSUME_NONNULL_BEGIN

@interface person : NSObject
///**
// name
// */
//@property(nonatomic , copy)NSString *name;
///**
// dic
// */
//@property(nonatomic , copy)NSDictionary *dic;
//
///**
// int
// */
//@property(nonatomic , assign)int count;
//
///**
// date
// */
//@property(nonatomic , strong)NSDate *date;
//
///**
// number
// */
//@property(nonatomic , strong)NSNumber *number;

///**
// son
// */
@property(nonatomic , strong)son *sonObject;
///**
// block
// */
//@property(nonatomic , copy)void (^block)(int a);

/**
 <#Description#>
 */
//@property(nonatomic , weak)id name;
@end

NS_ASSUME_NONNULL_END

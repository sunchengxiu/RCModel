//
//  RCModelProtocol.h
//  RCModel
//
//  Created by 孙承秀 on 2018/10/16.
//  Thank you for YY
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCModelProtocol <NSObject>
@optional

/**
 黑名单中的属性不会被解析

 @return 黑名单
 */
+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

/**
 只解析白名单中的属性
 
 @return 白名单
 */
+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;

/**
 自定义映射,某个属性映射到某个类（注：是映射到具体的类）
 {
    @"user":RCUser.class,
    @"address",@"RCAddress"
 }

 @return 自定义模型映射
 */
+ (nullable NSDictionary <NSString * , NSString *>*)modelCustomPropertyMapClass;

/**
 json->model 过程中，用该方法自定义字典中属性对应的自定义类
    + (Class)modelCustomClassForDictionary:(NSDictionary*)dictionary {
        if (dictionary[@"radius"] != nil) {
            return [RCCircle class];
        } else if (dictionary[@"width"] != nil) {
        r   eturn [RCRectangle class];
        } else if (dictionary[@"y2"] != nil) {
            return [RCLine class];
        } else {
            return [self class];
    }
 }

 @return 自定义映射
 */
+ (nullable NSDictionary <NSString * , NSString *>*)modelCustomClassForDictionary;
/**
 自定义键值对
 如果，我们的模型属性字段和 json 不对应，那么可以通过这个方法来自定义模型和json的键值对应关系
 
 Example:
 
 json:
 {
 "n":"sunchengxiu",
 "a": 25,
 "add" : {
    "home : "dalian"
 },
 "UID" : 88888
 }
 
 model:
 @code
 @interface RCUser : NSObject
    @property NSString *name;
    @property NSInteger age;
    @property NSString *home;
    @property NSString *ID;
 @end
 
 @implementation RCUser
 + (NSDictionary *)modelCustomPropertyMapper {
    return @{   @"name"  : @"n",
                @"age"  : @"a",
                @"home"  : @"add.home",
                @"ID": @[@"id", @"ID", @"UID"]};
    }
 @end
 @endcode
 
 其中 name 属于简单键值对映射，home 属于稍微复杂的 keypath 映射 ， ID 属于较为复杂的一对多映射。
 
 @return A custom mapper for properties.
 */
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;
@end

NS_ASSUME_NONNULL_END

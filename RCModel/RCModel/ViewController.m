//
//  ViewController.m
//  RCModel
//
//  Created by 孙承秀 on 2018/8/26.
//  Copyright © 2018 RongCloud. All rights reserved.
//

#import "ViewController.h"
#import "person.h"
#import <objc/runtime.h>
#import "NSObject+RCModel.h"
#import "WBModel.h"
@interface ViewController ()

/**
 scanner
 */
@property(nonatomic , strong)NSScanner *scanner;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    for (int i = 0; i <= 7; i++) {
        NSData *data = [NSData dataWithContentsOfFile:@"/Users/sunchengxiu/Desktop/RCKit/RCModel/RCModel/RCModel/weibo_0.json"];
                WBTimelineItem *item = [WBTimelineItem modelWithJson:data];
        NSLog(@"%@",item);
        //        for (WBStatus *status in item.statuses) {
        //            WBStatusLayout *layout = [[WBStatusLayout alloc] initWithStatus:status style:WBLayoutStyleTimeline];
        //            //                [layout layout];
        //            [_layouts addObject:layout];
        //        }
//    }
//
//    // 测试，获取person类的所有属性的编码
//    unsigned int count;
//    objc_property_t *property = class_copyPropertyList(person.class, &count);
//    for (unsigned int i = 0 ; i < count; i ++) {
//        objc_property_t _pro = property[i];
//        unsigned int attCount ;
//        objc_property_attribute_t *att = property_copyAttributeList(_pro, &attCount);
//        for (unsigned int j = 0 ; j < attCount; j ++ ) {
//            objc_property_attribute_t attribute = att[j];
//            NSLog(@"%c",att[j].name[0]);
//            NSLog(@"%s",att[j].name);
//
//        }
//    }
//
//    NSString *bananas = @"123.321abc137d efg/hij kl";
//    NSString *separatorString = @"fg";
//    BOOL result;
//
//    NSScanner *aScanner = [NSScanner scannerWithString:bananas];
//    NSString *temp;
////    result = [aScanner scanString:@"123." intoString:&temp];
//    BOOL r2 ;
//    NSString *t2;
//    r2 = [aScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"abcppp"] intoString:&t2];
////    NSLog(@"resule:%d---%@",result,temp);
//    NSLog(@"resule:%d---%@",r2,t2);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

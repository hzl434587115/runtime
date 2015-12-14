//
//  NSObject+Conversion.h
//  RuntimeDemo
//
//  Created by SDMac on 15/5/29.
//  Copyright (c) 2015年 SDMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Conversion)

/** 对应多个不同的key */
+ (NSDictionary*)KeyFromPropertyName;

/** 数组里对应的是什么类型的model */
+ (NSDictionary *)hzlObjectClassInArray;

/** 字典转model */
+ (id)setDataWithDic:(NSDictionary *)dic;

/** 简单字典转model */
+ (id)dictionaryToModel:(NSDictionary*)dictionary;

@end

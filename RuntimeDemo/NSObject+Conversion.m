//
//  NSObject+Conversion.m
//  RuntimeDemo
//
//  Created by SDMac on 15/5/29.
//  Copyright (c) 2015年 SDMac. All rights reserved.
//

#import "NSObject+Conversion.h"

@implementation NSObject (Conversion)

// 字典转模型,字典里的key值要和model里的属性名一致
+ (id)dictionaryToModel:(NSDictionary*)dictionary
{
    // 动态创建类
    id obj = [[self alloc]init];
    
    NSArray *dicArray = [dictionary allKeys];
    
    NSInteger outCount = (int)dicArray.count;
    
    for (NSInteger i = 0; i < outCount; i++)
    {
        // 获取字典的key值
        NSString *name = [dicArray objectAtIndex:i];
        
        // 根据key值获得value值
        NSString *value = [dictionary objectForKey:name];
        
        // 利用kvc把值设置给类
        [obj setValue:value forKey:name];
    }
    
    return obj;
}


@end

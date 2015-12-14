//
//  NSObject+Conversion.m
//  RuntimeDemo
//
//  Created by SDMac on 15/5/29.
//  Copyright (c) 2015年 SDMac. All rights reserved.
//

#import "NSObject+Conversion.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (Conversion)

// 字典数组转model数组
+ (NSArray*)setArrayWithDic:(NSArray*)array key:(NSString*)key
{
    NSMutableArray *modelArray = [NSMutableArray arrayWithCapacity:0];
    
    // 如果model类实现了hzlObjectClassInArray方法则返回数组中存储的类的类型
    if ([self respondsToSelector:@selector(hzlObjectClassInArray)])
    {
        // 1.获取用户实现的数组中存的是那种类型的model的字典
        NSDictionary *classDict = [self hzlObjectClassInArray];
        
        // 2.获得类型
        Class myClass = classDict[key];
        
        // 3.把字典数组转化为该类型的model
        for (NSDictionary *dict in array)
        {
            id model = [myClass setDataWithDic:dict];
            
            [modelArray addObject:model];
        }
        
        return modelArray;
    }
    
    return array;
}

// 字典转model
+ (id)setDataWithDic:(NSDictionary *)dic
{
    // 1.动态创建调用该方法的类的实例对象
    id object = [[self alloc]init];
    
    // 2.使用weak关键字创建弱引用指向该对象,防止在block中出现循环引用
    __weak __typeof(self) weakSelf = object;
    
    // 3.快速遍历字典
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
        // 4.获得调用该方法的类的属性名称
        NSString *propertyKey = [self propertyForKey:key];
        
        // 5.判断属性名称存不存在
        if (propertyKey)
        {
            // 6.判断这个值是什么类型
            if([obj isKindOfClass:[NSArray class]])
            {
                // 调用字典数组转模型数组
                NSArray *array = [self setArrayWithDic:obj key:propertyKey];
                
                // 利用kvc赋值
                [weakSelf setValue:array forKey:propertyKey];
            }
            else if([obj isKindOfClass:[NSString class]])
            {
                // 利用kvc赋值
                [weakSelf setValue:obj forKey:propertyKey];
            }
            else if([obj isKindOfClass:[NSDictionary class]])
            {
                // 根据名称获得属性
                objc_property_t property = class_getProperty([self class], [propertyKey UTF8String]);
                
                // 获得该属性是什么类型的类
                NSString *classString = [self getClassWtih:property];
                
                // 根据字符串创建类
                Class typeClass = NSClassFromString(classString);
                
                // 调用字典转模型
                id model = [typeClass setDataWithDic:obj];
                
                // 利用kvc赋值
                [weakSelf setValue:model forKey:propertyKey];
                
                NSLog(@"type is %@",[model class]);
            }
        }
    }];
    
    return object;
}

+ (NSString*)getClassWtih:(objc_property_t)property
{
    // 1.获取属性名称
    const char *name = property_getName(property);
    NSString *propertyName = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
    
    // 2.获取该属性的属性信息
    const char *attribute = property_getAttributes(property);
    NSString *attributeString = [NSString stringWithCString:attribute encoding:NSUTF8StringEncoding];
    
    // 3.截取字符串获取该属性属于的Class
    NSArray *stringArray = [attributeString componentsSeparatedByString:@","];
    NSString *typeString = stringArray[0];
    
    // 找到”T@"“的range
    NSRange rangeOne = [typeString rangeOfString:@"T@\""];
    
    // 根据他“T@"”的range确定Class的名称
    NSRange range = NSMakeRange(rangeOne.length + rangeOne.location,typeString.length - (rangeOne.length + rangeOne.location + 1));
    
    // 获取class的值
    NSString *classString = [typeString substringWithRange:range];
    
    NSLog(@"属性:%@\r\n类别:%@\r\n信息:%@", propertyName,typeString, attributeString);
    NSLog(@"类别:%@", classString);
    
    return classString;
}

// 获取key值
+ (NSString*)propertyForKey:(NSString*)key
{
    // 如果model类实现了KeyFromPropertyName方法则返回用户更改的key
    if ([self respondsToSelector:@selector(KeyFromPropertyName)])
    {
        NSString *string = [self KeyFromPropertyName][key];
        if (string.length > 0)
        {
            return string;
        }
        else
        {
            return key;
        }
    }
    
    return key;
}

// 字典转模型,字典里的key值要和model里的属性名一致
+ (id)dictionaryToModel:(NSDictionary*)dictionary
{
    // 1.动态创建调用该方法的类的实例对象
    id obj = [[self alloc]init];
    
    // 2.获取该字典中所有的key
    NSArray *keyArray = [dictionary allKeys];
    
    // 3.获取key的数量
    NSInteger keyCount = (int)keyArray.count;
    
    // 4.利用kvc把字典值设置给类对象的相应属性
    for (NSInteger i = 0; i < keyCount; i++)
    {
        // 5.获取字典的key值
        NSString *name = [keyArray objectAtIndex:i];
        
        // 6.根据key值获得value值
        NSString *value = [dictionary objectForKey:name];
        
        // 7.利用kvc设置对象的值
        [obj setValue:value forKey:name];
    }
    
    return obj;
}


@end

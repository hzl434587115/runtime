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
    if ([self respondsToSelector:@selector(KeyFromPropertyName)])
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
    
    return nil;
}

// 字典转model
+ (id)setDataWithDic:(NSDictionary *)dic
{
    id object = [[self alloc]init];
    
    __weak __typeof(self) weakSelf = object;
    
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
        NSString *propertyKey = [self propertyForKey:key];
        
        if (propertyKey)
        {
            if([obj isKindOfClass:[NSArray class]])
            {
                NSArray *array = [self setArrayWithDic:obj key:propertyKey];
                
                [weakSelf setValue:array forKey:propertyKey];
            }
            else if([obj isKindOfClass:[NSString class]])
            {
                [weakSelf setValue:obj forKey:propertyKey];
            }
            else if([obj isKindOfClass:[NSDictionary class]])
            {
                // 根据名称获得属性
                objc_property_t property = class_getProperty([self class], [propertyKey UTF8String]);
                
                NSString *classString = [self getClassWtih:property];
                
                Class typeClass = NSClassFromString(classString);
                
                id model = [typeClass setDataWithDic:obj];
                
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
    
    // 获取code值
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
    // 1.动态创建调用该方法的类
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

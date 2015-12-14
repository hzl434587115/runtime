//
//  Person.m
//  RuntimeDemo
//
//  Created by SDMac on 15/5/29.
//  Copyright (c) 2015年 SDMac. All rights reserved.
//

#import "Person.h"
@implementation Person

+ (NSDictionary*)KeyFromPropertyName
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:@"name" forKey:@"name1"];
    [dict setObject:@"age" forKey:@"age1"];
    [dict setObject:@"sex" forKey:@"sex1"];
    [dict setObject:@"name" forKey:@"name2"];
    [dict setObject:@"age" forKey:@"age2"];
    [dict setObject:@"sex" forKey:@"sex2"];
    
    return dict;
}

+ (NSDictionary *)hzlObjectClassInArray
{
    return @{@"myWife":[MyRunTime class]};
}

@end

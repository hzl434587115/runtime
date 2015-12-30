//
//  ViewController.m
//  RuntimeDemo
//
//  Created by SDMac on 15/5/29.
//  Copyright (c) 2015年 SDMac. All rights reserved.
//

#import "ViewController.h"

#import "Person.h"

#import "objc/runtime.h"

#import "NSObject+Conversion.h"

#import "MyRunTime.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSDictionary *dic1 = @{@"name":@"jack",@"status":@"101"};
    NSDictionary *dic2 = @{@"name":@"rosi",@"status":@"102"};
    NSArray *array = @[dic1,dic2];
    
    NSDictionary *dicA = @{@"name1":@"胡中磊",@"age1":@"26",@"sex1":@"男",@"runTime":dic1,@"myWife":array};
    
    Person *personA = [Person setDataWithDic:dicA];
    
    MyRunTime *model = personA.myWife[0];
    
    NSLog(@"name:%@,age:%@,sex:%@",personA.name,personA.age,personA.sex);
    
    NSLog(@"name:%@,status:%@",model.name,model.status);
    
    NSLog(@"name:%@,status:%@",personA.runTime.name,personA.runTime.status);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getAction:(UIButton *)sender
{
    //[self testA];
    Person *person = [[Person alloc]init];
    person.name = @"胡中磊";
    person.age = @"26";
    person.sex = @"男";
    
    [self getMethodList:person];
}

- (void)testA
{
    Person *person = [[Person alloc]init];
    person.name = @"胡中磊";
    person.age = @"26";
    person.sex = @"男";
    
    [self getPropertyList:person];
    
    //[self valueForPropertyName:person];
    
    //[self modelToDictionary:person];
    
    NSDictionary *dic = @{@"name":@"胡中磊",@"age":@"26",@"sex":@"男"};
    
    Person *wow = [Person dictionaryToModel:dic];
    
    NSLog(@"姓名:%@,年龄:%@,性别:%@",wow.name,wow.age,wow.sex);
    
    NSDictionary *dic1 = @{      @"format":@"json",
                                 @"kw":@"123",
                                 @"pageNo":@"235",};
    
    //[self getJsonWithDictionary:dic1];
    
    NSDictionary *dic2 = @{      @"format":@"json",
                                 @"kw":@"123",
                                 @"pageNo":@"235",};
    
    NSDictionary *dic3 = @{      @"format":@"json",
                                 @"kw":@"123",
                                 @"pageNo":@"235",};
    
    NSArray *ary = [NSArray arrayWithObjects:dic1,dic2,dic3,nil];
    
    //[self getJsonWithArray:ary];
}

- (void)testB
{
    // 判断一个方法能否执行
//    if ([self respondsToSelector:@selector(method)])
//    {
//        [self performSelector:@selector(method)];
//    }
    
    // 调用方法
    //objc_msgSend(receiver, selector)
}

// 获取一个类中所有的方法
- (void)getMethodList:(id)model
{
    unsigned int outCount, i;
    
    Method *methodList = class_copyMethodList ([model class], &outCount );
    
    for (i = 0; i < outCount; i++)
    {
        Method method = methodList[i];
        
        // 获取方法名称
        SEL sel = method_getName(method);
        
        const char *selName = sel_getName(sel);
        NSString *selString = [[NSString alloc] initWithCString:selName encoding:NSUTF8StringEncoding];
        
        const char *methodType = method_getTypeEncoding(method);
        NSString *methodString = [[NSString alloc] initWithCString:methodType encoding:NSUTF8StringEncoding];
        
        NSLog(@"方法名称:%@,Type:%@", selString,methodString);
    }
}

// 获取一个model类中所有的属性
-(void)getPropertyList:(id)model
{
    unsigned int outCount, i ,attributeCount ,j;
    
    // 运行时方法获取一个类的所有属性
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    
    // 运行时方法获取一个属性的特性列表
    objc_property_attribute_t *attributes = property_copyAttributeList(properties[3], &attributeCount);
    
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        
        // 获取属性名称
        const char *name = property_getName(properties[i]);
        
        // 指定特性的值
        char *value = property_copyAttributeValue(property, "T");
        
        NSString *propertyName = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
        NSString *attributeValue = [[NSString alloc] initWithCString:value encoding:NSUTF8StringEncoding];
        
        NSLog(@"属性名称:%@\n属性信息%s\n特性:%@", propertyName, property_getAttributes(property),attributeValue);
    }
    for (j = 0; j < attributeCount; j++)
    {
        objc_property_attribute_t attribute = attributes[j];
        
        NSString *attributeName = [[NSString alloc] initWithCString:attribute.name encoding:NSUTF8StringEncoding];
        NSString *attributeValue = [[NSString alloc] initWithCString:attribute.value encoding:NSUTF8StringEncoding];
        
        NSLog(@"特性名称:%@,特性值:%@", attributeName,attributeValue);
    }
}
// 获取model类中属性的值
-(void)valueForPropertyName:(id)model
{
    unsigned int outCount, i;
    
    // 获取属性列表
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    
    for (i = 0; i < outCount; i++)
    {
        // 获取属性名称
        const char *name = property_getName(properties[i]);
        
        NSString *propertyName = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
        
        // 拿到对应的value
        id value = [model valueForKey:propertyName];
        
        NSLog(@"%@",value);
    }
    
    // 因为copy 就要释放
    free(properties);
}
// 模型转字典
-(NSDictionary*)modelToDictionary:(id)model
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    unsigned int outCount, i;
    
    // 获取属性列表
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    
    for (i = 0; i < outCount; i++)
    {
        // 获取属性名称
        const char *name = property_getName(properties[i]);
        
        NSString *propertyName = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
        
        // 拿到对应的value
        id value = [model valueForKey:propertyName];
        
        [dic setValue:value forKey:propertyName];
    }
    
    //因为copy 就要释放
    free(properties);
    
    NSLog(@"%@",dic);
    
    return dic;
}
/**
 *  字典转模型
 *
 *  @param dictionary 传入字典
 *  @param className  model的类型
 *
 *  @return 返回转化的model
 */
- (id)dictionaryToModel:(NSDictionary*)dictionary ClassName:(NSString*)className
{
    // NSClassFromString(className) 根据类名获得类
    
    id obj = [[NSClassFromString(className) alloc] init];
    
    NSArray *dicArray = [dictionary allKeys];
    
    NSInteger outCount = (int)dicArray.count;
    
    for (NSInteger i = 0; i < outCount; i++)
    {
        // 获取字典的key值
        NSString *name = [dicArray objectAtIndex:i];
        
        NSString *value = [dictionary objectForKey:name];
        
        [obj setValue:value forKey:name];
    }
    
    return obj;
}
// 字典转json字符串
-(void)getJsonWithDictionary:(NSDictionary*)dic
{
    NSMutableString *jsonStr = [NSMutableString stringWithString:@"{"];
    
    for (NSInteger i =0;i<dic.allKeys.count;i++)
    {
        NSString *key = [dic.allKeys objectAtIndex:i];
        
        if (i + 1 != dic.allKeys.count)
        {
            [jsonStr appendFormat:@"%@:%@,",key,[dic objectForKey:key]];
        }
        else
        {
            [jsonStr appendFormat:@"%@:%@",key,[dic objectForKey:key]];
        }
    }
    [jsonStr appendFormat:@"}"];
    
    NSLog(@"字典转json:%@",jsonStr);
}

// 字典数组转json字符串
-(void)getJsonWithArray:(NSArray*)jsonAry
{
    
    NSMutableArray *ary = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDictionary *dic in jsonAry)
    {
        NSMutableString *jsonStr = [NSMutableString stringWithString:@"{"];
        
        for (NSInteger i =0;i<dic.allKeys.count;i++)
        {
            NSString *key = [dic.allKeys objectAtIndex:i];
            
            if (i + 1 != dic.allKeys.count)
            {
                [jsonStr appendFormat:@"%@:%@,",key,[dic objectForKey:key]];
            }
            else
            {
                [jsonStr appendFormat:@"%@:%@",key,[dic objectForKey:key]];
            }
        }
        [jsonStr appendFormat:@"}"];
        
        [ary addObject:jsonStr];
    }
    
    NSMutableString *jsonStr = [NSMutableString stringWithString:@"["];
    
    for (NSInteger i =0;i<ary.count;i++)
    {
        NSString *vlua = [ary objectAtIndex:i];
        
        if (i + 1 != ary.count)
        {
            [jsonStr appendFormat:@"%@,",vlua];
        }
        else
        {
            [jsonStr appendFormat:@"%@",vlua];
        }
    }
    [jsonStr appendFormat:@"]"];
    
    NSLog(@"数组转json:%@",jsonStr);
}

@end

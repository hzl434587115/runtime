//
//  MyRunTime.m
//  RuntimeDemo
//
//  Created by SDMac on 15/12/11.
//  Copyright © 2015年 SDMac. All rights reserved.
//

#import "MyRunTime.h"
#import <objc/runtime.h>
#import <objc/message.h>
@implementation MyRunTime

void TestMetaClass(id self, SEL _cmd){
    NSLog(@"This objcet is %p", self);
    NSLog(@"Class is %@, super class is %@", [self class], [self superclass]);
    
    Class currentClass = [self class];
    for (int i = 0; i < 4; i++) {
        NSLog(@"Following the isa pointer %d times gives %p", i, currentClass);
        currentClass = objc_getClass((__bridge void*)currentClass);
    }
    NSLog(@"NSObject's class is %p", [NSObject class]);
    NSLog(@"NSObject's meta class is %p", objc_getClass((__bridge void *)[NSObject class]));
}
// 创建一个类
+ (void)ex_registerClassPair
{
    // 1.创建一个类
    Class newClass = objc_allocateClassPair([NSError class], "TestClass", 0);
    
    // 2.给类添加一个方法
    
    // IMP 是函数指针
    // typedef id (*IMP)(id, SEL, ...);
//    IMP ivoid = imp_implementationWithBlock(^(id this,id some){
//        NSLog(@"%@",some);
//        return @111;
//    });
    // 注册方法名为testMetaClass的方法
    SEL s = sel_registerName("testMetaClass");
    class_addMethod(newClass, s, (IMP)TestMetaClass, "v@:");
    
    // 3为类添加变量
    //class_addIvar(newClass, "_name", sizeof(NSString*), log2(sizeof(NSString*)), @encode(NSString*));
    
    // 4.结束类的定义
    objc_registerClassPair(newClass);
    
    id instance = [[newClass alloc]initWithDomain:@"some domain" code:0 userInfo:nil];
    [instance performSelector:@selector(testMetaClass)];
}

@end

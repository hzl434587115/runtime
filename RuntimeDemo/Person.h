//
//  Person.h
//  RuntimeDemo
//
//  Created by SDMac on 15/5/29.
//  Copyright (c) 2015年 SDMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyRunTime.h"
@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, strong) MyRunTime *runTime;
@property (nonatomic, strong) NSArray *myWife;

@end

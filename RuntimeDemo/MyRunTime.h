//
//  MyRunTime.h
//  RuntimeDemo
//
//  Created by SDMac on 15/12/11.
//  Copyright © 2015年 SDMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyRunTime : NSObject

@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *status;

/** 用运行时创建一个类，并给类创建一个方法 */
+ (void)ex_registerClassPair;

@end

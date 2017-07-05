//
//  NSInvocation+Extension.h
//  FYNuggets
//
//  Created by 杨飞宇 on 2017/5/12.
//  Copyright © 2017年 FY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (Extension)

// 获取 NSInvocation 所有的参数
- (NSArray *)aspects_arguments;

@end

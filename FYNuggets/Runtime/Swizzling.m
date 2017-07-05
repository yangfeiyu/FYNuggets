//
//  Swizzling.m
//  FYNuggets
//
//  Created by 杨飞宇 on 2017/5/12.
//  Copyright © 2017年 FY. All rights reserved.
//

#import "Swizzling.h"
#import <objc/runtime.h>

@implementation Swizzling

- (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        // When swizzling a class method, use the following:
        // Class clazz = object_getClass((id)self);
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(fy_viewWillAppear:);
        
        Method originalMethod = class_getClassMethod(class, originalSelector);
        Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}


@end

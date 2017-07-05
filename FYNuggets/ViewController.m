//
//  ViewController.m
//  FYNuggets
//
//  Created by 杨飞宇 on 2017/5/12.
//  Copyright © 2017年 FY. All rights reserved.
//

#import "ViewController.h"
#import "TestObject.h"
#import "Runtime.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TestObject *object = [[TestObject alloc] init];
    
    Class klass = TestObject.class;
    
    SEL selector = @selector(test);
    
    IMP imp = fy_getMsgForwardIMP(object, selector);
    
    Method targetMethod = class_getInstanceMethod(klass, selector);
    
    const char *typeEncoding = method_getTypeEncoding(targetMethod);
    
    class_replaceMethod(klass, selector, imp, typeEncoding);
    
    [object test];
}



@end

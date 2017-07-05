//
//  TestObject.m
//  FYNuggets
//
//  Created by 杨飞宇 on 2017/5/12.
//  Copyright © 2017年 FY. All rights reserved.
//

#import "TestObject.h"
#import "Runtime.h"

@implementation TestObject

- (void)test {
    NSLog(@"test");
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    NSString selectorString = NSStringFromSelector(sel);
//    if ([selectorString isEqualToString:@"method1"]) {
//        class_addMethod(self.class, @selector(method1), (IMP)functionForMethod1, "@:");
//    }
    NSLog(@"resolveInstanceMethod");
    return [super resolveInstanceMethod:sel];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"forwardingTargetForSelector");
//    NSString selectorString = NSStringFromSelector(aSelector);
//    // 将消息转发给_helper来处理
//    if ([selectorString isEqualToString:@"method2"]) {
//        return _helper;
//    }
    return [super forwardingTargetForSelector:aSelector];
}

//- (NSMethodSignature )methodSignatureForSelector:(SEL)aSelector {
//    NSMethodSignature signature = [super methodSignatureForSelector:aSelector];
//    if (!signature) {
//        if ([SUTRuntimeMethodHelper instancesRespondToSelector:aSelector]) {
//            signature = [SUTRuntimeMethodHelper instanceMethodSignatureForSelector:aSelector];
//        }
//    }
//    return signature;
//}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"forwardInvocation");
//    if ([SUTRuntimeMethodHelper instancesRespondToSelector:anInvocation.selector]) {
//        [anInvocation invokeWithTarget:_helper];
//    }
}

@end

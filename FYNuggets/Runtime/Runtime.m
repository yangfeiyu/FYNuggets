//
//  Runtime.m
//  FYNuggets
//
//  Created by 杨飞宇 on 2017/5/12.
//  Copyright © 2017年 FY. All rights reserved.
//

#import "Runtime.h"
#import <objc/runtime.h>
#import <objc/message.h>

// 判断 IMP 是否为 _objc_msgForward 或者 _objc_msgForward_stret
BOOL fy_isMsgForwardIMP(IMP impl) {
    return impl == _objc_msgForward
#if !defined(__arm64__)
    || impl == (IMP)_objc_msgForward_stret
#endif
    ;
}

// 获取 _objc_msgForward 的IMP
IMP fy_getMsgForwardIMP(NSObject *self, SEL selector) {
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    // As an ugly internal runtime implementation detail in the 32bit runtime, we need to determine of the method we hook returns a struct or anything larger than id.
    // https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/LowLevelABI/000-Introduction/introduction.html
    // https://github.com/ReactiveCocoa/ReactiveCocoa/issues/783
    // http://infocenter.arm.com/help/topic/com.arm.doc.ihi0042e/IHI0042E_aapcs.pdf (Section 5.4)
    Method method = class_getInstanceMethod(self.class, selector);
    const char *encoding = method_getTypeEncoding(method);
    BOOL methodReturnsStructValue = encoding[0] == _C_STRUCT_B;
    if (methodReturnsStructValue) {
        @try {
            NSUInteger valueSize = 0;
            NSGetSizeAndAlignment(encoding, &valueSize, NULL);
            
            if (valueSize == 1 || valueSize == 2 || valueSize == 4 || valueSize == 8) {
                methodReturnsStructValue = NO;
            }
        } @catch (__unused NSException *e) {}
    }
    if (methodReturnsStructValue) {
        msgForwardIMP = (IMP)_objc_msgForward_stret;
    }
#endif
    return msgForwardIMP;
}

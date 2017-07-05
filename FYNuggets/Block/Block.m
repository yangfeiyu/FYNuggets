//
//  Block.m
//  FYNuggets
//
//  Created by 杨飞宇 on 2017/5/12.
//  Copyright © 2017年 FY. All rights reserved.
//

#import "Block.h"

// block layout
typedef NS_OPTIONS(int, FYBlockFlags) {
    FYBlockFlagsHasCopyDisposeHelpers = (1 << 25),
    FYBlockFlagsHasSignature          = (1 << 30)
};

typedef struct _FYBlock {
    __unused Class isa;
    FYBlockFlags flags;
    __unused int reserved;
    void (__unused *invoke)(struct _FYBlock *block, ...);   //
    struct {
        unsigned long int reserved;
        unsigned long int size;
        // requires AspectBlockFlagsHasCopyDisposeHelpers
        void (*copy)(void *dst, const void *src);
        void (*dispose)(const void *);
        // requires AspectBlockFlagsHasSignature
        const char *signature;
        const char *layout;
    } *descriptor;
    // imported variables
} *FYBlockRef;

// 获取 block 的 methodSignature
static NSMethodSignature *fy_blockMethodSignature(id block, NSError **error) {
    FYBlockRef layout = (__bridge void *)block;
    
    if (!(layout->flags & FYBlockFlagsHasSignature)) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't contain a type signature.", block];
        return nil;
    }
    
    void *desc = layout->descriptor;
    desc += 2 * sizeof(unsigned long int);
    if (layout->flags & FYBlockFlagsHasCopyDisposeHelpers) {
        desc += 2 * sizeof(void *);
    }
    
    if (!desc) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't has a type signature.", block];
        return nil;
    }
    const char *signature = (*(const char **)desc);
    return [NSMethodSignature signatureWithObjCTypes:signature];
}

// 检查blockSignature是否是兼容类型
static BOOL aspect_isCompatibleBlockSignature(NSMethodSignature *blockSignature, id object, SEL selector, NSError **error) {
    NSCParameterAssert(blockSignature);
    NSCParameterAssert(object);
    NSCParameterAssert(selector);
    
    BOOL signaturesMatch = YES;
    NSMethodSignature *methodSignature = [[object class] instanceMethodSignatureForSelector:selector];
    if (blockSignature.numberOfArguments > methodSignature.numberOfArguments) {
        signaturesMatch = NO;
    }else {
        if (blockSignature.numberOfArguments > 1) {
            const char *blockType = [blockSignature getArgumentTypeAtIndex:1];
            if (blockType[0] != '@') {
                signaturesMatch = NO;
            }
        }
        // Argument 0 is self/block, argument 1 is SEL or id<AspectInfo>. We start comparing at argument 2.
        // The block can have less arguments than the method, that's ok.
        if (signaturesMatch) {
            for (NSUInteger idx = 2; idx < blockSignature.numberOfArguments; idx++) {
                const char *methodType = [methodSignature getArgumentTypeAtIndex:idx];
                const char *blockType = [blockSignature getArgumentTypeAtIndex:idx];
                // Only compare parameter, not the optional type data.
                if (!methodType || !blockType || methodType[0] != blockType[0]) {
                    signaturesMatch = NO; break;
                }
            }
        }
    }
    
    if (!signaturesMatch) {
        NSString *description = [NSString stringWithFormat:@"Block signature %@ doesn't match %@.", blockSignature, methodSignature];
        return NO;
    }
    return YES;
}


//
//  Lock.m
//  FYNuggets
//
//  Created by 杨飞宇 on 2017/5/12.
//  Copyright © 2017年 FY. All rights reserved.
//

#import "Lock.h"
#import <libkern/OSAtomic.h>
#import <os/lock.h>

// OSSpinLock
static void fy_performLocked(dispatch_block_t block) {
    static OSSpinLock lock = OS_SPINLOCK_INIT;
    OSSpinLockLock(&lock);
    block();
    OSSpinLockUnlock(&lock);
}

static void fy_performLocked2(dispatch_block_t block) {
    static os_unfair_lock lock = OS_UNFAIR_LOCK_INIT;
    os_unfair_lock_lock(&lock);
    block();
    os_unfair_lock_unlock(&lock);
}

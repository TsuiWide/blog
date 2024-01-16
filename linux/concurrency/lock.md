# 并发
并发：对共享资源出现多条执行路径，导致对资源的访问出现竞争状态。并发不需要严格的时间意义上的同时执行。
## 并发源
* 中断处理路径
* 调度器的可抢占性
* 多处理器的并发执行

# local_irq_enable和local_irq_disable
local_irq_enable打开本地中断。

local_irq_disable关闭本地中断

两个宏定义依赖处理器体系架构，不同处理器需要不同指令来实现。

## local_irq_save和local_irq_restore
local_irq_save在关闭irq之前保存中断状态到flags里

local_irq_restore将flags里的状态恢复到处理器。

# spinlock
处理器系统上对共享资源的保护。

在临界区内不可睡眠。

情形：
* 内核可抢占和内核不可抢占
* 多处理器和单处理器

分类：
* spin_lock
* spin_lock_irq
* spin_lock_irqsave
* spin_lock_bh

# rwlock
任何时刻只有一个写入者进入临界区，可以有多个读取者同事进入临界区。

进程想去读取共享资源时，必须检查是否有进程正在写，有的话必须自旋等待。

进程想去写的话，必须检查是否有进程正在**写**或者**读**，有的话必须自旋等待。

写入者和读取者都有各自的lock函数

```
read_lock()
read_lock_irq()
read_lock_irqsave()

read_unlock()
read_unlock_irq()
read_unlock_irqrestore()

write_lock()
write_lock_irq()
write_lock_irqsave()

write_unlock()
write_unlock_irq()
write_unlock_irqrestore()
```


# semaphore

允许调用的进程进入睡眠状态。在试图或者某一信号量时可能会失去cpu控制器，出现进程切换。

```
struct semaphore {
    lock;
    count;
    wait_list;
}
count
允许进入临界区的执行路径个数
wait_list
无法获取该信号量的进程加入到该wait_list中
```

## DOWN
当sem->count <= 0时，无法获取信号量，就会调用down系列函数等待。最终调用的函数为__down_common。
```
__down_common() {
	list_add_tail(&waiter.list, &sem->wait.list);
	waiter.up = 0;
	for(;;) {
		spin_lock_irq()
		timeout = schedule_timeout()
		spin_lock_irqsave()
		if (waiter.up)
			return 0;
	}
}
```
## UP
如果wait_list不为空，说明有其他进程正在等待。调用__up(sem)来唤醒进程。

**即使不是信号量的拥有者，也可以调用up函数来释放一个信号量。**
这个和mutex是不同的

# rwsem
读取者和写入者都有各自的DOWN操作和UP操作


# mutex
用count=1的信号量可以实现互斥方法，但是linux内核重新定义了一个新的数据结构struct mutex来实现互斥锁。

```
struct mutex
```

拥有互斥锁的进程总会在尽可能短的时间内释放锁。

互斥锁的DOWN操作

互斥锁的UP操作

DOWN和UP都是fast和slow两条path

# seqlock
对某一数据读取的时候不加锁，写的时候加锁。

在读取者和写入者之间引入一个整型变量，称为顺序值sequence。读取者在开始读取者前读取该sequence，在读取后再重新读该值，如果和之前读取
的值不一致，则说明本次读取操作过程中发生了数据更新，读取操作无效。

写入者在开始写入时候更新sequence的值。

# RCU
Read-Copy-Update

linux内核中的一种免锁机制

实现原理：将读取者和写入者要访问的共享数据放在一个指针p中，读取者通过p来访问共享数据，而写入者通过修改p来更新数据。

## 写入者的RCU操作
写入者重新分配一个被保护的共享数据区，将老数据区的数据复制到新数据区，然后根据需要修改新数据区，最后用新数据区指针替换掉老的指针，
替换指针的操作是一个原子操作，不需要与读取者进行互斥操作。在写入者完成这些工作后，后续所有的RCU读取操作都将访问到这个新的共享数据区。

## 释放老指针
写入者更新共享数据区的指针后，还不能马上释放老指针，因为系统中还有可能存在对老指针的引用。写入者在更新指针后会向内核注册一个回调函数，
内核在确定所有对老指针的引用都结束后会调用改回调函数，回调函数会释放老指针指向的内存空间。

回调函数调用时机：所用处理器上都至少发生过一次进程切换。

# 原子变量和位操作
atomic_*开头的原子操作函数

因为atomic_t是一个struct，所以在需要整型变量的地方不能直接用atomic_t变量，否则会产生编译错误。

# 等待队列wait_queue
等待队列不是一种互斥机制。等待队列本质是一个双向链表，由等待队列头和队列节点构成。当获取的资源不能得到时，进程需要等待，进入睡眠状态。


# 完成量completion
completion用在多个执行路径间作同步是用。

如果在complete后需要继续该completion，应该调用INIT_COMPLETION宏重新初始化completion->done的值。



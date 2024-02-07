参考
* [【原创】Linux中断子系统（四）-Workqueue ](https://www.cnblogs.com/LoyenWang/p/13185451.html)
* [任务工厂 - Linux 中的 workqueue 机制 [一]](https://zhuanlan.zhihu.com/p/91106844)

# workqueue
一种延迟执行的方法

workqueue在内核里主要有两个版本：
* a multi threaded (MT) wq had one worker thread per CPU。and a single threaded (ST) wq had one worker thread system-wide
* Concurrency Managed Workqueue

Concurrency Managed Workqueue (cmwq) is a reimplementation of wq with focus on the following goals.
* Maintain compatibility with the original workqueue API.
* Use per-CPU unified worker pools shared by all wq to provide flexible level of concurrency on demand without wasting a lot of resource.
* Automatically regulate worker pool and level of concurrency so that the API users don't need to worry about such details.

# 第一个版本
## 数据结构
```
v6.8-rc1/source/include/linux/workqueue_types.h#L16
struct work_struct {
	atomic_long_t data;
	struct list_head entry;
	work_func_t func;
#ifdef CONFIG_LOCKDEP
	struct lockdep_map lockdep_map;
#endif
};
```
工作节点对象，通过queue_work函数将该工作节点提交给工作队列。


# 第二个版本
Concurrency Managed Workqueue

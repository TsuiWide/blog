# PIC interrupt
CLICK here for a quick [PIC interrupt tutorial](https://www.microcontrollerboard.com/support-files/pic_micro_interrupts.pdf)

可编程中断控制器PIC(Programmable Interrupt Controller)和处理器的INT中断引脚连接。同时PIC和外部设备的中断线连在一起。PCI会将外设的中断引脚编号映射到处理器可见的终端号irq。当某一外设发生中断时，PCI在INT引脚上产生一个中断信号告诉处理器，处理器得到一个特定的标识号码，中断处理器调用对应号码的中断处理例程。这个特定的标识号码就是中断号irq。

# 通用中断处理函数
中断发生：

* 当前任务的上下文寄存器保存在一个特定的中断栈中
* 屏蔽处理器相应外部中断的能力
* 根据中断向量表中的外部中断对应的入口地址，调用系统提供的通用处理函数。不同架构的通用中断处理函数实现不同，大部分都会执行一下步骤：

    * 从PIC得到中断号irq
    * 调用do_IRQ类似的函数
    * 从do_IRQ返回后恢复中断前的工作环境
    * 如果没有开启内核可抢占，被中断的任务开始继续执行。如果开启了内核可抢占，如果之前被中断的路径在内核态，中断返回是会启用调度器以确定是否进行进程切换。

linux内核为驱动程序提供的中断处理机制分为两部分：HARDIRQ和SOFTIRQ。

# do_IRQ
```
do_IRQ(irq, *regs)
{
	old_regs = set_irq_regs(regs);
	irq_enter();
	check_stack_overflow();
	generic_handle_irq(irq);
	irq_exit();
	set_irq_regs(old_regs);
}

generic_handle_irq(irq)
{
	desc = &irq_desc[irq];
	desc->handle_irq(irq, desc);
}
```
核心函数是generic_handle_irq

通过irq来索引数组irq_desc，得到一个struct irq_desc类型的指针变量desc。irq_desc数组在整个中断处理框架中非常重要，起着沟通从通用中断处理函数到设备特定的中断处理例程之间的桥梁作用。

irq_desc的初始化是在early_irq_init中。

```
struct irq_desc irq_desc[NR_IRQS] = {
}

<include/linux/irqdesc.h>
struct irq_desc {
	struct irq_data;
	unsigned int *kstat_irqs;
	irq_flow_handler_t handle_irq;
	struct irqaction *action;
	unsigned int istate；
}

struct irq_data {
	unsigned int irq;
	struct irq_chip *chip;
}
irq记录的是irq中断号。
chip抽象的是当前中断来自的PIC。
```

unsigned int *kstat_irqs;
中断次数统计

irq_flow_handler_t handle_irq;
中断触发电信号类型相关的函数

struct irqaction *action;
action是对某一设置具体的中断处理函数的抽象。设备驱动程序通过request_irq函数来挂载特定设备的中断处理函数。相对于通用中断处理函数，一般称该action中的handle为设备中断服务例程ISR。

中断处理分成两个层次，第一层是handle_irq函数，它与中断号irq一一对应，代表了对IRQ line上的处理动作。第二层action则代表了与具体设备相关的中断处理函数。

一条IRQ line上可以挂载多个设备来达到共享一个中断号irq的目的。

unsigned int istate；
记录当前中断线IRQ line上的状态。

## irq_chip
```
struct irq_chip {

}
```
用来指向具体平台实现的PIC控制函数。

## struct irqaction
```
struct irq_desc irq_desc[NR_IRQS] = {
}

<include/linux/irqdesc.h>
struct irq_desc {
	struct irqaction *action;
}

struct irqaction {
	irq_handle_t handler;
	void *dev_id;
	struct irqaction *next;
	int irq;
}
```

irq_handle_t handler;
指向设备特定的中断服务例程函数ISR。

## irq_set_handler
中断处理两级：

* 调用irq_desc[irq].handle_irq。handle_irq函数在平台初始化期间被安装到irq_desc数组中。
* 设备特定的中断处理例程ISR，在handle_irq的内部通过irq_desc[irq].action->handler调用。设备驱动程序通过request_irq安装对应的设备中断例程。

平台注册第一级中断处理函数使用的函数接口：
1.	irq_set_handler
2.	irq_set_chained_handler

两个函数最后都会调用__irq_set_handler(irq, handle, is_chained, *name);is_chained用了表示irq_desc[irq]对应项是否支持中断共享。

irq_desc[irq].status_use_accessors用了设置对IRQ line的一些配置响应。
* _IRQ_NOREQUEST无法通过request_irq来安装ISR。
* _IRQ_NOPROBE无法使用中断号探测机制。

支持中断共享，那么肯定就不能支持自动探测，这是由自动探测机制决定的。

流程
* 系统初始化平台
* 平台调用irq相关的初始化函数
* irq_set_handler(int irq, struct irq_flow_handler_t handle);例如:irq_set_handler(i, handle_edge_irq)
  * irq_desc[irq].handle_irq = handle;
* 当IRQ line出现中断信息时，系统调用irq_desc[irq].handle_irq。

例子：handle_edge_irq
```
v6.8-rc1/source/kernel/irq/chip.c#L787
void handle_edge_irq(unsigned int irq, struct irq_desc *desc)
{
	...
	do {
		...
		handle_irq_event(desc);
	} while ((desc->istate & IRQS_PENDING) && !irqd_irq_disabled(&desc->irq_data));
}
```

## handle_irq_event
为调用设备驱动程序安装的中断处理例程ISR做最后的准备工作。
```
irqreturn_t handle_irq_event(struct irq_desc *desc)
{
	ret = handle_irq_event_percpu(desc);
}

irqreturn_t handle_irq_event_percpu(struct irq_desc *desc)
{
	retval = __handle_irq_event_percpu(desc);
}

irqreturn_t __handle_irq_event_percpu(struct irq_desc *desc)
{
	for_each_action_of_desc(desc, action) {
		trace_irq_handler_entry(irq, action);
		res = action->handler(irq, action->dev_id);
		trace_irq_handler_exit(irq, action, res);
		switch (res) {
		case IRQ_WAKE_THREAD:
			__irq_wake_thread(desc, action);
			break;
		default:
			break;
		}
	}
}
```
真正的设备驱动中断例程调用发生在action->handler(irq, action->dev_id);

## request_irq
```
v6.8-rc1/source/include/linux/interrupt.h#L165
static inline int __must_check
request_irq(unsigned int irq, irq_handler_t handler, unsigned long flags,
	    const char *name, void *dev)
{
	return request_threaded_irq(irq, handler, NULL, flags, name, dev);
}

int request_threaded_irq(unsigned int irq, irq_handler_t handler,
			 irq_handler_t thread_fn, unsigned long irqflags,
			 const char *devname, void *dev_id)
{
	struct irqaction *action;
	struct irq_desc *desc;
	int retval;

	if (irq == IRQ_NOTCONNECTED)
		return -ENOTCONN;

	/*
	 * Sanity-check: shared interrupts must pass in a real dev-ID,
	 * otherwise we'll have trouble later trying to figure out
	 * which interrupt is which (messes up the interrupt freeing
	 * logic etc).
	 *
	 * Also shared interrupts do not go well with disabling auto enable.
	 * The sharing interrupt might request it while it's still disabled
	 * and then wait for interrupts forever.
	 *
	 * Also IRQF_COND_SUSPEND only makes sense for shared interrupts and
	 * it cannot be set along with IRQF_NO_SUSPEND.
	 */
	if (((irqflags & IRQF_SHARED) && !dev_id) ||
	    ((irqflags & IRQF_SHARED) && (irqflags & IRQF_NO_AUTOEN)) ||
	    (!(irqflags & IRQF_SHARED) && (irqflags & IRQF_COND_SUSPEND)) ||
	    ((irqflags & IRQF_NO_SUSPEND) && (irqflags & IRQF_COND_SUSPEND)))
		return -EINVAL;

	desc = irq_to_desc(irq);

	if (!handler) {
		if (!thread_fn)
			return -EINVAL;
		handler = irq_default_primary_handler;
	}

	action = kzalloc(sizeof(struct irqaction), GFP_KERNEL);

	action->handler = handler;
	action->thread_fn = thread_fn;
	action->flags = irqflags;
	action->name = devname;
	action->dev_id = dev_id;

	retval = irq_chip_pm_get(&desc->irq_data);

	retval = __setup_irq(irq, desc, action);

	return retval;
}
EXPORT_SYMBOL(request_threaded_irq);
```
request_irq函数的核心是通过调用request_threaded_irq完成中断处理例程函数ISR的安装工作。

request_irq调用时request_threaded_irq的参数thread_fn为NULL，不会涉及到irq_thread。

如果驱动通过request_threaded_irq来安装中断。此时就有机会使用到irq_thread机制。

### desc->action为空
尚无设备驱动程序使用这IRQ line.直接将struct irqaction *old, **old_ptr = &desc->action;
### desc->action不为空
已经有中断处理函数安装到该IRQ line。需要做一些判断，大体原则是：新安装的中断例程不能破坏之前已有的中断工作模式。

被检查的标志有IRQF_SHARED、IRQF_TRIGGER_MASK、IRQF_ONESHOT、IRQF_PERCPU.

## 中断处理中irq_thread机制
通过request_threaded_irq来安装中断例程，内部会生成一个名为irq_thread的独立线程。发生中断时action->handler只负责唤醒睡眠的irq_thread，后者调用action->thread_fn进行实际的中断处理工作。

irq_thread本质上是一个独立线程，所以这种中断机制的中断处理工作发生在进程空间。

```
v6.8-rc1/source/kernel/irq/manage.c#L1505
static int
__setup_irq(unsigned int irq, struct irq_desc *desc, struct irqaction *new)
{
	/*
	 * Create a handler thread when a thread function is supplied
	 * and the interrupt does not nest into another interrupt
	 * thread.
	 */
	if (new->thread_fn && !nested) {
		ret = setup_irq_thread(new, irq, false);
		if (ret)
			goto out_mput;
		if (new->secondary) {
			ret = setup_irq_thread(new->secondary, irq, true);
			if (ret)
				goto out_thread;
		}
	}
}

static int
setup_irq_thread(struct irqaction *new, unsigned int irq, bool secondary)
{
	struct task_struct *t;

	if (!secondary) {
		t = kthread_create(irq_thread, new, "irq/%d-%s", irq,
				   new->name);
	} else {
		t = kthread_create(irq_thread, new, "irq/%d-s-%s", irq,
				   new->name);
	}

	if (IS_ERR(t))
		return PTR_ERR(t);

	/*
	 * We keep the reference to the task struct even if
	 * the thread dies to avoid that the interrupt code
	 * references an already freed task_struct.
	 */
	new->thread = get_task_struct(t);
	/*
	 * Tell the thread to set its affinity. This is
	 * important for shared interrupt handlers as we do
	 * not invoke setup_affinity() for the secondary
	 * handlers as everything is already set up. Even for
	 * interrupts marked with IRQF_NO_BALANCE this is
	 * correct as we want the thread to move to the cpu(s)
	 * on which the requesting code placed the interrupt.
	 */
	set_bit(IRQTF_AFFINITY, &new->thread_flags);
	return 0;
}
```

## free_irq
释放不需要的中断处理函数。

如果action->dev_id == dev_id，就找到了对应要释放的action。

## SOFTIRQ
```
v6.8-rc1/source/kernel/softirq.c#L654
void irq_exit(void)
{
	__irq_exit_rcu();
	ct_irq_exit();
	 /* must be last! */
	lockdep_hardirq_exit();
}

static inline void __irq_exit_rcu(void)
{
	account_hardirq_exit(current);
	preempt_count_sub(HARDIRQ_OFFSET);
	if (!in_interrupt() && local_softirq_pending())
		invoke_softirq();

	tick_irq_exit();
}
```

### preempt_count()
preempt_count变量，判断当前是否在一个中断上下文中执行。

         NMI HARDIRQ  SOFTIRQ  PREEMPT

|-----------|-|-------|-------|-------|

### do_softirq
SOFTIRQ核心函数do_softirq

内核定义了一个struct softirq_action类型的数组softirq_vec

```
https://elixir.bootlin.com/linux/v6.8-rc1/source/kernel/softirq.c#L59
static struct softirq_action softirq_vec[NR_SOFTIRQS] __cacheline_aligned_in_smp;
const char * const softirq_to_name[NR_SOFTIRQS] = {
	"HI", "TIMER", "NET_TX", "NET_RX", "BLOCK", "IRQ_POLL",
	"TASKLET", "SCHED", "HRTIMER", "RCU"
};
```

## irq的自动探测
前提：设备的irq号不会跟别的设备共享
情形：该设备关联到某个irq，但是设备驱动不知道该irq号是多少。

原理:调用probe_irq_on遍历整个irq_desc数组，对每个action为空且该项允许自动探测的情形下，将istate的IRQS_WAITING置为1，然后设备产生一次中断，与设备关联的IRQ line上发出中断信息，调用第一级中断的handle_irq函数，handle_irq将istate的IRQS_WAITING清零。然后调用probe_irq_off再遍历一次irq_desc数组，对于action为空且istate的IRQS_WAITING=0的desc对应的irq就是与设备关联的。

## 中断共享
中断号不够用的时候需要启用中断共享。在调用request_irq时使用IRQ_SHARED标识，同时提供dev_id。
dev_id主要是在free_irq起作用。


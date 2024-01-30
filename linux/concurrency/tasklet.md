# tasklet

tasklet是内核定义的softirq中的TASKLET_SOFTIRQ和HI_SOFTIRQ。HI_SOFTIRQ的优先级要高一些。
```
v6.8-rc1/source/include/linux/interrupt.h#L561
enum
{
	HI_SOFTIRQ=0,
	TIMER_SOFTIRQ,
	NET_TX_SOFTIRQ,
	NET_RX_SOFTIRQ,
	BLOCK_SOFTIRQ,
	IRQ_POLL_SOFTIRQ,
	TASKLET_SOFTIRQ,
	SCHED_SOFTIRQ,
	HRTIMER_SOFTIRQ,
	RCU_SOFTIRQ,    /* Preferable RCU should always be the last softirq */

	NR_SOFTIRQS
};
```

# tasklet初始化
内核初始化期间调用softirq_init时为TASKLET_SOFTIRQ和HI_SOFTIRQ配置了执行函数tasklet_action和tasklet_hi_action。
```
void __init softirq_init(void)
{
	int cpu;

	for_each_possible_cpu(cpu) {
		per_cpu(tasklet_vec, cpu).tail =
			&per_cpu(tasklet_vec, cpu).head;
		per_cpu(tasklet_hi_vec, cpu).tail =
			&per_cpu(tasklet_hi_vec, cpu).head;
	}

	open_softirq(TASKLET_SOFTIRQ, tasklet_action);
	open_softirq(HI_SOFTIRQ, tasklet_hi_action);
}
```
for_each_possible_cpu表明每个cpu都有本地tasklet_vec和tasklet_hi_vec副本。
```
v6.8-rc1/source/kernel/softirq.c#L893
void open_softirq(int nr, void (*action)(struct softirq_action *))
{
	softirq_vec[nr].action = action;
}

v6.8-rc1/source/kernel/softirq.c#L59
static struct softirq_action softirq_vec[NR_SOFTIRQS] __cacheline_aligned_in_smp;
```
当执行soft_irq中断处理函数时，会遍历softirq_vec数组，分别执行softirq_vec[TASKLET_SOFTIRQ].action和softirq_vec[HI_SOFTIRQ].action，所以最终会调用到tasklet_action和tasklet_hi_action。

# 提交tasklet
内核定义一个tasklet对象的数据结构体
```
v6.8-rc1/source/include/linux/interrupt.h#L642
struct tasklet_struct
{
	struct tasklet_struct *next;
	unsigned long state;
	atomic_t count;
	bool use_callback;
	union {
		void (*func)(unsigned long data);
		void (*callback)(struct tasklet_struct *t);
	};
	unsigned long data;
};
```
struct tasklet_struct *next;系统中的所有tasklet对象链接起来的链表。

unsigned long state;
```
v6.8-rc1/source/include/linux/interrupt.h#L648
enum
{
	TASKLET_STATE_SCHED,	/* Tasklet is scheduled for execution */
	TASKLET_STATE_RUN	/* Tasklet is running (SMP only) */
};
```
atomic_t count;实现tasklet的disable和enable操作，为0时表示当前的tasklet是enabled的，可以被调度。

void (*func)(unsigned long data);延迟执行的函数。

unsigned long data;延迟函数调用时，可以作为函数的参数。

## 声明一个tasklet
```
#define DECLARE_TASKLET(name, _callback)		\
struct tasklet_struct name = {				\
	.count = ATOMIC_INIT(0),			\
	.callback = _callback,				\
	.use_callback = true,				\
}

#define DECLARE_TASKLET_DISABLED(name, _callback)	\
struct tasklet_struct name = {				\
	.count = ATOMIC_INIT(1),			\
	.callback = _callback,				\
	.use_callback = true,				\
}
```

## 初始化tasklet
```
v6.8-rc1/source/kernel/softirq.c#L825
void tasklet_init(struct tasklet_struct *t,
		  void (*func)(unsigned long), unsigned long data)
{
	t->next = NULL;
	t->state = 0;
	atomic_set(&t->count, 0);
	t->func = func;
	t->use_callback = false;
	t->data = data;
}
EXPORT_SYMBOL(tasklet_init);
```

## 提交tasklet
通过tasklet_schedule和tasklet_hi_schedule提交。
```
v6.8-rc1/source/kernel/softirq.c#L714
static void __tasklet_schedule_common(struct tasklet_struct *t,
				      struct tasklet_head __percpu *headp,
				      unsigned int softirq_nr)
{
	struct tasklet_head *head;
	unsigned long flags;

	local_irq_save(flags);
	head = this_cpu_ptr(headp);
	t->next = NULL;
	*head->tail = t;
	head->tail = &(t->next);
	raise_softirq_irqoff(softirq_nr);
	local_irq_restore(flags);
}

void __tasklet_schedule(struct tasklet_struct *t)
{
	__tasklet_schedule_common(t, &tasklet_vec,
				  TASKLET_SOFTIRQ);
}
EXPORT_SYMBOL(__tasklet_schedule);

void __tasklet_hi_schedule(struct tasklet_struct *t)
{
	__tasklet_schedule_common(t, &tasklet_hi_vec,
				  HI_SOFTIRQ);
}
```

tasklet_vec和tasklet_hi_vec分别是per-CPU变量。
```
v6.8-rc1/source/kernel/softirq.c#L711
static DEFINE_PER_CPU(struct tasklet_head, tasklet_vec);
static DEFINE_PER_CPU(struct tasklet_head, tasklet_hi_vec);
```

## tasklet_action
```
v6.8-rc1/source/kernel/softirq.c#L758
static void tasklet_action_common(struct softirq_action *a,
				  struct tasklet_head *tl_head,
				  unsigned int softirq_nr)
{
	struct tasklet_struct *list;

	local_irq_disable();
	list = tl_head->head;
	tl_head->head = NULL;
	tl_head->tail = &tl_head->head;
	local_irq_enable();

	while (list) {
		struct tasklet_struct *t = list;

		list = list->next;

		if (tasklet_trylock(t)) {
			if (!atomic_read(&t->count)) {
				if (tasklet_clear_sched(t)) {
					if (t->use_callback) {
						trace_tasklet_entry(t, t->callback);
						t->callback(t);
						trace_tasklet_exit(t, t->callback);
					} else {
						trace_tasklet_entry(t, t->func);
						t->func(t->data);
						trace_tasklet_exit(t, t->func);
					}
				}
				tasklet_unlock(t);
				continue;
			}
			tasklet_unlock(t);
		}

		local_irq_disable();
		t->next = NULL;
		*tl_head->tail = t;
		tl_head->tail = &t->next;
		__raise_softirq_irqoff(softirq_nr);
		local_irq_enable();
	}
}

static __latent_entropy void tasklet_action(struct softirq_action *a)
{
	tasklet_action_common(a, this_cpu_ptr(&tasklet_vec), TASKLET_SOFTIRQ);
}

static __latent_entropy void tasklet_hi_action(struct softirq_action *a)
{
	tasklet_action_common(a, this_cpu_ptr(&tasklet_hi_vec), HI_SOFTIRQ);
}

```

* **一个处于TASKLET_STATE_SCHED状态的tasklet对象不能别多次提交**
* **处理器A在SOFTIRQ中断时处理被schedule的tasklet时，会清除TASKLET_STATE_SCHED。如果处理器B发生中断后也提交了一个同样的tasklet。那么处理器A和B有可能会同时运行同一个tasklet对象。tasklet_action_common会针对这种情形做出专门的处理。**
* **在tasklet_action_common的while循环中，会遍历tasklet_vec链表。如果tasklet节点不满足执行条件（哪些情形会不满足？），会将该tasklet重新加入tasklet_vec链表。**


tasklet_trylock查询一个tasklet没有处于TASKLET_STATE_RUN状态。如果没有TASKLET_STATE_RUN，则该tasklet就可以在该cpu上执行。如果是TASKLET_STATE_RUN，则表明该tasklet已经在执行，则不能再次被调度。这样就解决了同一个tasklet在不同的处理器上同时运行的问题。

```
v6.8-rc1/source/include/linux/interrupt.h#L691
#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT_RT)
static inline int tasklet_trylock(struct tasklet_struct *t)
{
	return !test_and_set_bit(TASKLET_STATE_RUN, &(t)->state);
}
```

atomic_read对tasklet的count进行判断。某个tasklet的count为0，则处于enable状态，否则是disable。
```
v6.8-rc1/source/kernel/softirq.c#L776
if (tasklet_trylock(t)) {
	if (!atomic_read(&t->count)) {
		if (tasklet_clear_sched(t)) {
			if (t->use_callback) {
				trace_tasklet_entry(t, t->callback);
				t->callback(t);
				trace_tasklet_exit(t, t->callback);
			} else {
				trace_tasklet_entry(t, t->func);
				t->func(t->data);
				trace_tasklet_exit(t, t->func);
			}
		}
		tasklet_unlock(t);
		continue;
	}
	tasklet_unlock(t);
}
```

tasklet_clear_sched会测试t->state中的TASKLET_STATE_SCHED位，一个被提交的tasklet对象该位会被置为1。如果测试成功，会将该位清0。**这也意味着除非再次提交该tasklet，softirq才会调度到它，这是一种one-shot特性。**
```
v6.8-rc1/source/kernel/softirq.c#L744
static bool tasklet_clear_sched(struct tasklet_struct *t)
{
	if (test_and_clear_bit(TASKLET_STATE_SCHED, &t->state)) {
		wake_up_var(&t->state);
		return true;
	}

	WARN_ONCE(1, "tasklet SCHED state not set: %s %pS\n",
		  t->use_callback ? "callback" : "func",
		  t->use_callback ? (void *)t->callback : (void *)t->func);

	return false;
}
```

## tasklet其他操作
```
tasklet_disable()
tasklet_disable_nosync()
tasklet_enable()
tasklet_kill()
```

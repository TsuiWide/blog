# 进程管理和调度
---
# 内存管理
## 物理内存
## 缓存

---

# 进程虚拟内存

---

# 进程间通信

---

# 同步机制

---

# 设备驱动程序

---

# 设备驱动模型
## 概述
### 数据类型
#### 内部构成的数据结构
1. kobject
2. kset
#### 对外展示的数据结构
1. bus
2. driver
3. device
## kobject

参考
* [Linux 内核：设备驱动模型（1）sysfs与kobject基类](https://www.cnblogs.com/schips/p/linux_device_model_1.html)

内核用kobject表示一个内核对象.
将一个kobject对象加入系统中，对应的结果反映到/sys目录中就是一个新目录的建立或者消亡。除了向用户空间展示不同kobject的层次关系。还可以通过文件系统接口配置kobject对象的属性。
```
struct kobject {
	const char		*name; //内核对象名字，出现在sysfs文件系统中，表现为一个新的目录名
	struct list_head	entry; //一系列内核对象链表
	struct kobject		*parent; //内核对象上层节点。由此引入内核对象层次化关系
	struct kset		*kset; //所属的kset对象指针
	const struct kobj_type	*ktype;
	struct kernfs_node	*sd; /* sysfs directory entry */
	struct kref		kref; // 引用计数
#ifdef CONFIG_DEBUG_KOBJECT_RELEASE
	struct delayed_work	release;
#endif
	unsigned int state_initialized:1;
	unsigned int state_in_sysfs:1;
	unsigned int state_add_uevent_sent:1;
	unsigned int state_remove_uevent_sent:1;
	unsigned int uevent_suppress:1; //所在的kset是否向用户空间发送event消息
};
```
kobject嵌入在表示某一对象的数据结构中，比如cdev对象
```
kobject_set_name
kobject_init
kobject_add
```
kobject_add作用
1. 建立kobject对象之间的层次关系
2. 在sysfs文件系统中建立一个目录。

设置kobject属性
```
struct kobj_type {
	void (*release)(struct kobject *kobj);
	const struct sysfs_ops *sysfs_ops;
	const struct attribute_group **default_groups;
	const struct kobj_ns_type_operations *(*child_ns_type)(const struct kobject *kobj);
	const void *(*namespace)(const struct kobject *kobj);
	void (*get_ownership)(const struct kobject *kobj, kuid_t *uid, kgid_t *gid);
};
```
为一个kobject对象创建一个属性文件的方法： int stsfs_create_file(struct kobject *kobj, const struct attribute *attr)

## kset
kset可以认为是一组kobject的集合，是kobject的容器。kset本身也是一个内核对象，所以需要内嵌一个kobject对象。


---

# 模块

---

# 文件系统
## 分类
1. 基于磁盘的文件系统
2. 内核伪文件系统
3. 网络文件系统
### 内核伪文件系统
内核中生成，是一种用户应用程序与内核通信的方法
#### 类型
1. procfs
2. sysfs
3. debugfs
#### procfs
The proc filesystem is a pseudo-filesystem which provides an interface to kernel data structures.
挂载点/proc
历史最早，最初就是用来跟内核交互的唯一方式，用来获取处理器、内存、设备驱动、进程等各种信息。
Documentation/filesystems/proc.txt
#### sysfs
The filesystem for exporting kernel objects.
挂载点/sys
跟 kobject 框架紧密联系，而 kobject 是为设备驱动模型而存在的，所以 sysfs 是为设备驱动服务的。
Documentation/filesystems/sysfs.txt
初始化位于内核启动阶段

```
sysfs_init()
    register_filesystem(&sysfs_fs_type);
        sys_init_inode()
```
#### debugfs
Debugfs exists as a simple way for kernel developers to make information available to user space.
挂载点/sys/kernel/debug
从名字来看就是为debug而生，所以更加灵活。
Documentation/filesystems/debugfs.txt

# 时间管理

---

# 网络

---

# 未归类

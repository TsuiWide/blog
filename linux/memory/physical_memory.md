# 内存模型

物理内存划分为一页一页的内存块，每页大小为 4K。
一页大小的内存块在内核中用 struct page 结构体来进行管理，struct page 中封装了每页内存块的状态信息。
为了快速索引到具体的物理内存页，内核为每个物理页 struct page 结构体定义了一个索引编号：PFN（Page Frame Number）。PFN 与 struct page 是一一对应的关系。
内核提供了两个宏来完成 PFN 与 物理页结构体 struct page 之间的相互转换。它们分别是 page_to_pfn 与 pfn_to_page。

## FLATMEM 平坦内存模型
物理内存是连续的，物理地址也是连续的，划分出来的这一页一页的物理页也是连续的，并且每页的大小都是固定的。

## DISCONTIGMEM 非连续内存模型
在 DISCONTIGMEM 非连续内存模型中，内核将物理内存从宏观上划分成了一个一个的节点 node （微观上还是一页一页的物理页），每个 node 节点管理一块连续的物理内存。这样一来这些连续的物理内存页均被划归到了对应的 node 节点中管理，就避免了内存空洞造成的空间浪费。

## SPARSEMEM 稀疏内存模型
SPARSEMEM 稀疏内存模型的核心思想就是对粒度更小的连续内存块进行精细的管理，用于管理连续内存块的单元被称作 section。

# 内存架构

## 一致性内存访问 UMA 架构
UMA（Uniform Memory Access）
内存是一个整体，所有的 CPU 访问内存都要过总线，而且距离都是一样的。

## 非一致性内存访问 NUMA 架构
NUMA（Non-uniform memory access）
内存被分为一个一个节点(NUMA节点)。每个 CPU 都有属于自己的本地内存节点，CPU 访问自己的本地内存不需要经过总线，因此访问速度是最快的。

## 节点管理
```
/include/linux/mmzone.h
extern pg_data_t *pgdat_list;
typedef struct pglist_data {
    struct pglist_data *pgdat_next;
}

/arch/arm64/include/asm/mmzone.h
#ifdef CONFIG_NUMA
extern struct pglist_data *node_data[];
#define NODE_DATA(nid)  (node_data[(nid)])
```

## 节点物理内存区域的划分
每个节点按照功能划分成不同的区域
```
enum zone_type {
#ifdef CONFIG_ZONE_DMA
 ZONE_DMA,
#endif
#ifdef CONFIG_ZONE_DMA32
 ZONE_DMA32,
#endif
 ZONE_NORMAL,
#ifdef CONFIG_HIGHMEM
 ZONE_HIGHMEM,
#endif
 ZONE_MOVABLE,
#ifdef CONFIG_ZONE_DEVICE
 ZONE_DEVICE,
#endif
    // 充当结束标记, 在内核中想要迭代系统中所有内存域时, 会用到该常量
 __MAX_NR_ZONES
};
```
```
struct zone {
    // 防止并发访问该内存区域
    spinlock_t      lock;
    // 内存区域名称：Normal ，DMA，HighMem
    const char      *name;
    // 指向该内存区域所属的 NUMA 节点
    struct pglist_data  *zone_pgdat;
    // 属于该内存区域中的第一个物理页 PFN
    unsigned long       zone_start_pfn;
    // 该内存区域中所有的物理页个数（包含内存空洞）
    unsigned long       spanned_pages;
    // 该内存区域所有可用的物理页个数（不包含内存空洞）
    unsigned long       present_pages;
    // 被伙伴系统所管理的物理页数
    atomic_long_t       managed_pages;
    // 伙伴系统的核心数据结构
    struct free_area    free_area[MAX_ORDER];
    // 该内存区域内存使用的统计信息
    atomic_long_t       vm_stat[NR_VM_ZONE_STAT_ITEMS];
} ____cacheline_internodealigned_in_smp;
typedef struct pglist_data {
    // NUMA 节点中的物理内存区域个数
    int nr_zones; 
    // NUMA 节点中的物理内存区域
    struct zone node_zones[MAX_NR_ZONES];
}
```

## 物理内存区域中的水位线
在内核中，物理内存页有两种类型，针对这两种类型的物理内存页，内核会有不同的回收机制。<br>
第一种就是文件页。读取的磁盘数据缓存在 page cache 中，page cache 里存放的就是文件页。在进程中通过  fsync()  系统调用将指定文件的所有脏页同步回写到磁盘，同时内核也会根据一定的条件唤醒专门用于回写脏页的 pflush 内核线程。<br>
另外一种物理页类型是匿名页，所谓匿名页就是它背后并没有一个磁盘中的文件作为数据来源，匿名页中的数据都是通过进程运行过程中产生的，比如我们应用程序中动态分配的堆内存。匿名页的回收机制就是我们经常看到的 Swap 机制。<br>
内核会为每个 NUMA 节点中的每个物理内存区域定制三条用于指示内存容量的水位线，分别是：WMARK_MIN（页最小阈值）， WMARK_LOW （页低阈值），WMARK_HIGH（页高阈值）。<br>
```
enum zone_watermarks {
 WMARK_MIN,
 WMARK_LOW,
 WMARK_HIGH,
 NR_WMARK
};
struct zone {
    // 物理内存区域中的水位线
    unsigned long _watermark[NR_WMARK];
    // 优化内存碎片对内存分配的影响，可以动态改变内存区域的基准水位线。
    unsigned long watermark_boost;

} ____cacheline_internodealigned_in_smp;
```
水位线的计算是通过**__setup_per_zone_wmarks**得到的。


参考
* [一步一图带你深入理解 Linux 物理内存管理](https://mp.weixin.qq.com/s?__biz=Mzg2MzU3Mjc3Ng==&mid=2247486879&idx=1&sn=0bcc59a306d59e5199a11d1ca5313743&chksm=ce77cbd8f90042ce06f5086b1c976d1d2daa57bc5b768bac15f10ee3dc85874bbeddcd649d88&cur_album_id=2559805446807928833&scene=189#wechat_redirect)

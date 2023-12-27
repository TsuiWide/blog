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


参考
* [一步一图带你深入理解 Linux 物理内存管理](https://mp.weixin.qq.com/s?__biz=Mzg2MzU3Mjc3Ng==&mid=2247486879&idx=1&sn=0bcc59a306d59e5199a11d1ca5313743&chksm=ce77cbd8f90042ce06f5086b1c976d1d2daa57bc5b768bac15f10ee3dc85874bbeddcd649d88&cur_album_id=2559805446807928833&scene=189#wechat_redirect)

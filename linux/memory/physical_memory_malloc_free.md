# 内核物理内存分配接口
物理内存分配接口全部是基于伙伴系统的。分配的物理内存页全部都是物理上连续的，并且只能分配 2 的整数幂个页。
```
struct page *alloc_pages(gfp_t gfp, unsigned int order);
#define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
```
内核又提供了一个函数 __get_free_pages ，该函数直接返回物理内存页的虚拟内存地址。用户可以直接使用。
```
unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
#define __get_free_page(gfp_mask) \
  __get_free_pages((gfp_mask), 0)
```
**__get_free_pages不能申请ZONE_HIGHMEM的内存**

物理内存释放
```
void __free_pages(struct page *page, unsigned int order);
void free_pages(unsigned long addr, unsigned int order);
```
# 掩码 gfp_mask

## 物理区域的修饰
NUMA 节点内的物理内存划分为：ZONE_DMA，ZONE_DMA32，ZONE_NORMAL，ZONE_HIGHMEM 这几个物理内存区域。<br>
前缀 gfp 是 get free page 的缩写，意思是在获取空闲物理内存页的时候需要指定的分配掩码 gfp_mask。<br>
按照 ZONE_HIGHMEM -> ZONE_NORMAL -> ZONE_DMA  的顺序依次降级。<br>
定义在文件：/include/linux/gfp.h<br>
```
static inline enum zone_type gfp_zone(gfp_t flags)
{
 enum zone_type z;
 int bit = (__force int) (flags & GFP_ZONEMASK);

 z = (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
      ((1 << GFP_ZONES_SHIFT) - 1);
 VM_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
 return z;
}
```

## 分配行为的修饰符
```
#define ___GFP_RECLAIMABLE 0x10u
#define ___GFP_HIGH  0x20u
#define ___GFP_IO  0x40u
#define ___GFP_FS  0x80u
#define ___GFP_ZERO  0x100u
#define ___GFP_ATOMIC  0x200u
#define ___GFP_DIRECT_RECLAIM 0x400u
#define ___GFP_KSWAPD_RECLAIM 0x800u
#define ___GFP_NOWARN  0x2000u
#define ___GFP_RETRY_MAYFAIL 0x4000u
#define ___GFP_NOFAIL  0x8000u
#define ___GFP_NORETRY  0x10000u
#define ___GFP_HARDWALL  0x100000u
#define ___GFP_THISNODE  0x200000u
#define ___GFP_MEMALLOC  0x20000u
#define ___GFP_NOMEMALLOC 0x80000u
```

## gfp_t 掩码组合
```
#define GFP_ATOMIC (__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
#define GFP_KERNEL (__GFP_RECLAIM | __GFP_IO | __GFP_FS)
#define GFP_NOWAIT (__GFP_KSWAPD_RECLAIM)
#define GFP_NOIO (__GFP_RECLAIM)
#define GFP_NOFS (__GFP_RECLAIM | __GFP_IO)
#define GFP_USER (__GFP_RECLAIM | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
#define GFP_DMA  __GFP_DMA
#define GFP_DMA32 __GFP_DMA32
#define GFP_HIGHUSER (GFP_USER | __GFP_HIGHMEM)
```

# 物理内存分配内核源码实现
**__alloc_pages 函数为 Linux 内核内存分配的核心入口函数**

内核使用了一个大小为 MAX_NUMNODES 的全局数组 node_data[] 来管理所有的 NUMA 节点，数组的下标即为 NUMA 节点 Id。

## 分配行为标识掩码 ALLOC_*
影响内核分配内存行为的标识，这些重要标识定义在内核文件 /mm/internal.h 中

```
#define ALLOC_WMARK_MIN     WMARK_MIN
#define ALLOC_WMARK_LOW     WMARK_LOW
#define ALLOC_WMARK_HIGH    WMARK_HIGH
#define ALLOC_NO_WATERMARKS 0x04 /* don't check watermarks at all */

#define ALLOC_HARDER         0x10 /* try to alloc harder */
#define ALLOC_HIGH       0x20 /* __GFP_HIGH set */
#define ALLOC_CPUSET         0x40 /* check for correct cpuset */

#define ALLOC_KSWAPD        0x800 /* allow waking of kswapd, __GFP_KSWAPD_RECLAIM set */
```

## __alloc_pages
```
/*
 * This is the 'heart' of the zoned buddy allocator.
 */
struct page *__alloc_pages(gfp_t gfp, unsigned int order, int preferred_nid,
                            nodemask_t *nodemask)
{
    // 用于指向分配成功的内存
    struct page *page;
    // 内存区域中的剩余内存需要在 WMARK_LOW 水位线之上才能进行内存分配，否则失败（初次尝试快速内存分配）
    unsigned int alloc_flags = ALLOC_WMARK_LOW;
    // 之前小节中介绍的内存分配掩码集合
    gfp_t alloc_gfp; 
    // 用于在不同内存分配辅助函数中传递参数
    struct alloc_context ac = { };

    // 检查用于向伙伴系统申请内存容量的分配阶 order 的合法性
    // 内核定义最大分配阶 MAX_ORDER -1 = 10，也就是说一次最多只能从伙伴系统中申请 1024 个内存页。
    if (WARN_ON_ONCE_GFP(order >= MAX_ORDER, gfp))
        return NULL;
    // 表示在内存分配期间进程可以休眠阻塞
    gfp &= gfp_allowed_mask;

    alloc_gfp = gfp;
    // 初始化 alloc_context，并为接下来的快速内存分配设置相关 gfp
    if (!prepare_alloc_pages(gfp, order, preferred_nid, nodemask, &ac,
            &alloc_gfp, &alloc_flags))
        // 提前判断本次内存分配是否能够成功，如果不能则尽早失败
        return NULL;

    // 避免内存碎片化的相关分配标识设置，可暂时忽略
    alloc_flags |= alloc_flags_nofragment(ac.preferred_zoneref->zone, gfp);

    // 内存分配快速路径：第一次尝试从底层伙伴系统分配内存，注意此时是在 WMARK_LOW 水位线之上分配内存
    page = get_page_from_freelist(alloc_gfp, order, alloc_flags, &ac);
    if (likely(page))
        // 如果内存分配成功则直接返回
        goto out;
    // 流程走到这里表示内存分配在快速路径下失败
    // 这里需要恢复最初的内存分配标识设置，后续会尝试更加激进的内存分配策略
    alloc_gfp = gfp;
    // 恢复最初的 node mask 因为它可能在第一次内存分配的过程中被改变
    // 本函数中 nodemask 起初被设置为 null
    ac.nodemask = nodemask;

    // 在第一次快速内存分配失败之后，说明内存已经不足了，内核需要做更多的工作
    // 比如通过 kswap 回收内存，或者直接内存回收等方式获取更多的空闲内存以满足内存分配的需求
    // 所以下面的过程称之为慢速分配路径
    page = __alloc_pages_slowpath(alloc_gfp, order, &ac);

out:
    // 内存分配成功，直接返回 page。否则返回 NULL
    return page;
}
```


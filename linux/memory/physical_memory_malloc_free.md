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
**__alloc_pages 函数为 Linux 内核内存分配的核心入口函数**<br>
内核使用了一个大小为 MAX_NUMNODES 的全局数组 node_data[] 来管理所有的 NUMA 节点，数组的下标即为 NUMA 节点 Id。<br>




# How to point GDB to your sources

## gdb source path
usually used command：
>1.set substitute-path /local/xukuan/repo/gdb_demo /home/xukuan/repo/gdb_demo
>2.directory /home/xukuan/repo/gdb_demo

## Debug info
compiler with -g option
to find whether your program has debug symbols, you can list the sections of the binary with objdump:
>$ objdump -h -w libgbd.so
libgbd.so:     file format elf64-x86-64
\
Sections:****
Idx Name          Size      VMA               LMA               File off  Algn  Flags
  0 .note.gnu.build-id 00000024  00000000000001c8  00000000000001c8  000001c8  2**2  CONTENTS, ALLOC, LOAD, READONLY, DATA
  1 .gnu.hash     00004f54  00000000000001f0  00000000000001f0  000001f0  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .dynsym       00010848  0000000000005148  0000000000005148  00005148  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .dynstr       00011675  0000000000015990  0000000000015990  00015990  2**0  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .gnu.version  00001606  0000000000027006  0000000000027006  00027006  2**1  CONTENTS, ALLOC, LOAD, READONLY, DATA
  5 .gnu.version_r 000000c0  0000000000028610  0000000000028610  00028610  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
  6 .rela.dyn     0000b970  00000000000286d0  00000000000286d0  000286d0  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
  7 .rela.plt     0000bb68  0000000000034040  0000000000034040  00034040  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
  8 .init         0000001a  000000000003fba8  000000000003fba8  0003fba8  2**2  CONTENTS, ALLOC, LOAD, READONLY, CODE
  9 .plt          00007d00  000000000003fbd0  000000000003fbd0  0003fbd0  2**4  CONTENTS, ALLOC, LOAD, READONLY, CODE
 10 .plt.got      00000068  00000000000478d0  00000000000478d0  000478d0  2**3  CONTENTS, ALLOC, LOAD, READONLY, CODE
 11 .text         005a0e29  0000000000047940  0000000000047940  00047940  2**4  CONTENTS, ALLOC, LOAD, READONLY, CODE
 12 .fini         00000009  00000000005e876c  00000000005e876c  005e876c  2**2  CONTENTS, ALLOC, LOAD, READONLY, CODE
 13 .rodata       0006aaa8  00000000005e8780  00000000005e8780  005e8780  2**5  CONTENTS, ALLOC, LOAD, READONLY, DATA
 14 .eh_frame_hdr 000094b4  0000000000653228  0000000000653228  00653228  2**2  CONTENTS, ALLOC, LOAD, READONLY, DATA
 15 .eh_frame     00025c94  000000000065c6e0  000000000065c6e0  0065c6e0  2**3  CONTENTS, ALLOC, LOAD, READONLY, DATA
 16 .init_array   00000018  0000000000882710  0000000000882710  00682710  2**3  CONTENTS, ALLOC, LOAD, DATA
 17 .fini_array   00000018  0000000000882728  0000000000882728  00682728  2**3  CONTENTS, ALLOC, LOAD, DATA
 18 .dynamic      00000240  0000000000882740  0000000000882740  00682740  2**3  CONTENTS, ALLOC, LOAD, DATA
 19 .got          00000680  0000000000882980  0000000000882980  00682980  2**3  CONTENTS, ALLOC, LOAD, DATA
 20 .got.plt      00003e90  0000000000883000  0000000000883000  00683000  2**3  CONTENTS, ALLOC, LOAD, DATA
 21 .data         00046600  0000000000886ea0  0000000000886ea0  00686ea0  2**5  CONTENTS, ALLOC, LOAD, DATA
 22 .bss          00002108  00000000008cd4a0  00000000008cd4a0  006cd4a0  2**5  ALLOC
 23 .comment      0000002e  0000000000000000  0000000000000000  006cd4a0  2**0  CONTENTS, READONLY
 24 .debug_aranges 000015f0  0000000000000000  0000000000000000  006cd4ce  2**0  CONTENTS, READONLY, DEBUGGING
 25 .debug_info   00b7e1bd  0000000000000000  0000000000000000  006ceabe  2**0  CONTENTS, READONLY, DEBUGGING
 26 .debug_abbrev 0001e888  0000000000000000  0000000000000000  0124cc7b  2**0  CONTENTS, READONLY, DEBUGGING
 27 .debug_line   000e32b7  0000000000000000  0000000000000000  0126b503  2**0  CONTENTS, READONLY, DEBUGGING
 28 .debug_str    0007ea1d  0000000000000000  0000000000000000  0134e7ba  2**0  CONTENTS, READONLY, DEBUGGING
 29 .debug_ranges 0000e690  0000000000000000  0000000000000000  013cd1d7  2**0  CONTENTS, READONLY, DEBUGGING

or readelf:

>$ readelf -S -W libgbd.so
There are 34 section headers, starting at offset 0x14389c0:
\
Section Headers:
  [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
  [ 1] .note.gnu.build-id NOTE            00000000000001c8 0001c8 000024 00   A  0   0  4
  [ 2] .gnu.hash         GNU_HASH        00000000000001f0 0001f0 004f54 00   A  3   0  8
  [ 3] .dynsym           DYNSYM          0000000000005148 005148 010848 18   A  4   2  8
  [ 4] .dynstr           STRTAB          0000000000015990 015990 011675 00   A  0   0  1
  [ 5] .gnu.version      VERSYM          0000000000027006 027006 001606 02   A  3   0  2
  [ 6] .gnu.version_r    VERNEED         0000000000028610 028610 0000c0 00   A  4   4  8
  [ 7] .rela.dyn         RELA            00000000000286d0 0286d0 00b970 18   A  3   0  8
  [ 8] .rela.plt         RELA            0000000000034040 034040 00bb68 18  AI  3  21  8
  [ 9] .init             PROGBITS        000000000003fba8 03fba8 00001a 00  AX  0   0  4
  [10] .plt              PROGBITS        000000000003fbd0 03fbd0 007d00 10  AX  0   0 16
  [11] .plt.got          PROGBITS        00000000000478d0 0478d0 000068 00  AX  0   0  8
  [12] .text             PROGBITS        0000000000047940 047940 5a0e29 00  AX  0   0 16
  [13] .fini             PROGBITS        00000000005e876c 5e876c 000009 00  AX  0   0  4
  [14] .rodata           PROGBITS        00000000005e8780 5e8780 06aaa8 00   A  0   0 32
  [15] .eh_frame_hdr     PROGBITS        0000000000653228 653228 0094b4 00   A  0   0  4
  [16] .eh_frame         PROGBITS        000000000065c6e0 65c6e0 025c94 00   A  0   0  8
  [17] .init_array       INIT_ARRAY      0000000000882710 682710 000018 00  WA  0   0  8
  [18] .fini_array       FINI_ARRAY      0000000000882728 682728 000018 00  WA  0   0  8
  [19] .dynamic          DYNAMIC         0000000000882740 682740 000240 10  WA  4   0  8
  [20] .got              PROGBITS        0000000000882980 682980 000680 08  WA  0   0  8
  [21] .got.plt          PROGBITS        0000000000883000 683000 003e90 08  WA  0   0  8
  [22] .data             PROGBITS        0000000000886ea0 686ea0 046600 00  WA  0   0 32
  [23] .bss              NOBITS          00000000008cd4a0 6cd4a0 002108 00  WA  0   0 32
  [24] .comment          PROGBITS        0000000000000000 6cd4a0 00002e 01  MS  0   0  1
  [25] .debug_aranges    PROGBITS        0000000000000000 6cd4ce 0015f0 00      0   0  1
  [26] .debug_info       PROGBITS        0000000000000000 6ceabe b7e1bd 00      0   0  1
  [27] .debug_abbrev     PROGBITS        0000000000000000 124cc7b 01e888 00      0   0  1
  [28] .debug_line       PROGBITS        0000000000000000 126b503 0e32b7 00      0   0  1
  [29] .debug_str        PROGBITS        0000000000000000 134e7ba 07ea1d 01  MS  0   0  1
  [30] .debug_ranges     PROGBITS        0000000000000000 13cd1d7 00e690 00      0   0  1
  [31] .shstrtab         STRTAB          0000000000000000 1438881 00013f 00      0   0  1
  [32] .symtab           SYMTAB          0000000000000000 13db868 02f340 18     33 5239  8
  [33] .strtab           STRTAB          0000000000000000 140aba8 02dcd9 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), l (large)
  I (info), L (link order), G (group), T (TLS), E (exclude), x (unknown)
  O (extra OS processing required) o (OS specific), p (processor specific)

as we see in our fresh compiled libgbd.so - it has .debug_* section, hence it has debug info.

##How GDB finds source code
>$ objdump -g libgbd.so | vim -
Contents of the .debug_info section:
\
   Compilation Unit @ offset 0x0:
   Length:        0x18653 (32-bit)
   Version:       4
   Abbrev Offset: 0x0
   Pointer Size:  8
 <0>\<b>: Abbrev Number: 1 (DW_TAG_compile_unit)
    \<c>   DW_AT_producer    : (indirect string, offset: 0x16c5f): GNU C11 7.4.0 -mtune=generic -march=x86-64 -g -g -O0 -O0 -fno-strict-aliasing -fPIC -fstack-protector-strong
    <10>   DW_AT_language    : 12   (ANSI C99)
    <11>   DW_AT_name        : (indirect string, offset: 0x10f5e): gdb_demo.c
    <15>   DW_AT_comp_dir    : (indirect string, offset: 0x21b04): /local/xukuan/repo/gdb_demo/src
    <19>   DW_AT_low_pc      : 0x47a1a
    <21>   DW_AT_high_pc     : 0x4c6a
    <29>   DW_AT_stmt_list   : 0x0

It reads like this - for address range from DW_AT_low_pc = 0x47a1a to DW_AT_low_pc + DW_AT_high_pc = 0x47a1a + 0x4c6a = 0x4be0b source code file is the gdb_demo.c located in /local/xukuan/repo/gdb_demo/src. Pretty straightforward.

So this is what happens when GDB tries to show you the source code:

parses the .debug_info to find DW_AT_comp_dir with DW_AT_name attributes for the current object file (range of addresses)
opens the file at DW_AT_comp_dir/DW_AT_name
shows the content of the file to you

## How to tell GDB where are the sources
1. Reconstruct the sources path
You can reconstruct the sources path on the target host, so GDB will find the source file where it expects. Stupid but it will work.
2. Change GDB source path
You can direct GDB to the new source path right in the debug session with directory \<dir> command:
>(gdb) list
13      gdb_demo.c: No such file or directory.
(gdb) directory /home/xukuan/repo/gdb_demo
Source directories searched: /home/xukuan/repo/gdb_demo:$cdir:$cwd
(gdb) list
6	#ifdef \_\_FreeBSD\_\_
7	#include <fenv.h>
8	#endif
9	
10	#ifdef MS_WINDOWS
11	int
12	wmain(int argc, wchar_t **argv)
13	{
14	    return Py_Main(argc, argv);
15	}

3. Set GDB substitution rule
Sometimes adding another source path is not enough if you have complex hierarchy. In this case you can add substitution rule for source path with set substitute-path GDB command.

>(gdb) list
5      target.c: No such file or directory.
(gdb) set substitute-path /local/xukuan/repo/gdb_demo /home/xukuan/repo/gdb_demo
(gdb) list
(gdb) list
6	#ifdef \_\_FreeBSD\_\_
7	#include <fenv.h>
8	#endif
9	
10	#ifdef MS_WINDOWS
11	int
12	wmain(int argc, wchar_t **argv)
13	{
14	    return Py_Main(argc, argv);
15	}

1. Move binary to sources
2. Compile with -fdebug-prefix-map

- [How to point GDB to your sources](https://alex.dzyoba.com/blog/gdb-source-path/)

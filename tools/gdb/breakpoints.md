# breakpoints
## save breakpoints

```
(gdb) info  b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x00007ffff6de997a in vxopadTensor at main.c:365
        breakpoint already hit 1 time
2       breakpoint     keep y   0x00007ffff6de9a9d in vxpadTensor at main.c:380
(gdb) save breakpoints gdb.cfg
Saved to file 'gdb.cfg'.
```
execute application by gdb again

```
(gdb) info b
No breakpoints or watchpoints.
(gdb) set breakpoint pending on
(gdb) source gdb.cfg
Function "vxpadTensor" not defined.
Breakpoint 1 (vxpadTensor) pending.
Breakpoint 2 at 0x7ffff6de9a9d
```
>before source gdb.cfg need do **set breakpoint pending on** first.
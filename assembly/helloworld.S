 .globl _start

_start:

  vsetivli t0, 10, e8 //AVL=10, vtype=8bit // 8bitが10個
  la a1, string
  vle8.v v30, (a1)

  li a0, -32
  vadd.vx v30, v30, a0
  vse8.v v30, (a1)

  # print
  li a0, 1
  la a1, string
  li a2, 12 // string length
  li a7, 64 // write system call
  ecall

  li a0, 0
  li a7, 93 #exit system call
  ecall

  .data 
  .align 8
string:
  .ascii "helloworld!\n"
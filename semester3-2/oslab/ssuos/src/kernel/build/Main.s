	.file	"Main.c"
	.text
.Ltext0:
	.comm	Glob_x,4,4
	.comm	Glob_y,4,4
	.comm	hash_table,13824,32
	.globl	VERSION
	.section	.rodata
.LC0:
	.string	"0.1.02"
	.data
	.align 4
	.type	VERSION, @object
	.size	VERSION, 4
VERSION:
	.long	.LC0
	.globl	AUTHOR
	.section	.rodata
.LC1:
	.string	"OSLAB"
	.data
	.align 4
	.type	AUTHOR, @object
	.size	AUTHOR, 4
AUTHOR:
	.long	.LC1
	.globl	MODIFIER
	.section	.rodata
.LC2:
	.string	"You"
	.data
	.align 4
	.type	MODIFIER, @object
	.size	MODIFIER, 4
MODIFIER:
	.long	.LC2
	.text
	.globl	ssuos_main
	.type	ssuos_main, @function
ssuos_main:
.LFB18:
	.file 1 "arch/Main.c"
	.loc 1 28 0
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$8, %esp
	.loc 1 29 0
	call	main_init
	.loc 1 31 0
	subl	$12, %esp
	pushl	$0
	call	idle
	addl	$16, %esp
	.loc 1 33 0
	nop
	.loc 1 34 0
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE18:
	.size	ssuos_main, .-ssuos_main
	.section	.rodata
.LC3:
	.string	"Memory Detecting\n"
.LC4:
	.string	"%s"
.LC5:
	.string	"-Memory size = %u Kbytes\n"
.LC6:
	.string	"PIT Intialization\n"
.LC7:
	.string	"System call Intialization\n"
.LC8:
	.string	"Interrupt Initialization\n"
.LC9:
	.string	"%sPalloc Initialization\n"
.LC10:
	.string	"Paging Initialization\n"
.LC11:
	.string	"Hash Table Initialization\n"
.LC12:
	.string	"Process Intialization\n"
	.align 4
.LC13:
	.string	"========== initialization complete ==========\n\n"
	.text
	.globl	main_init
	.type	main_init, @function
main_init:
.LFB19:
	.loc 1 37 0
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$8, %esp
	.loc 1 38 0
	call	intr_disable
	.loc 1 41 0
	call	init_console
	.loc 1 43 0
	call	print_contributors
	.loc 1 45 0
	call	detect_mem
	.loc 1 46 0
	subl	$8, %esp
	pushl	$.LC3
	pushl	$.LC4
	call	printk
	addl	$16, %esp
	.loc 1 47 0
	call	mem_size
	shrl	$10, %eax
	subl	$8, %esp
	pushl	%eax
	pushl	$.LC5
	call	printk
	addl	$16, %esp
	.loc 1 49 0
	call	init_pit
	.loc 1 50 0
	subl	$8, %esp
	pushl	$.LC6
	pushl	$.LC4
	call	printk
	addl	$16, %esp
	.loc 1 52 0
	call	init_syscall
	.loc 1 53 0
	subl	$8, %esp
	pushl	$.LC7
	pushl	$.LC4
	call	printk
	addl	$16, %esp
	.loc 1 55 0
	call	init_intr
	.loc 1 56 0
	subl	$8, %esp
	pushl	$.LC8
	pushl	$.LC4
	call	printk
	addl	$16, %esp
	.loc 1 58 0
	call	init_kbd
	.loc 1 60 0
	call	init_palloc
	.loc 1 61 0
	subl	$12, %esp
	pushl	$.LC9
	call	printk
	addl	$16, %esp
	.loc 1 63 0
	call	init_paging
	.loc 1 64 0
	subl	$8, %esp
	pushl	$.LC10
	pushl	$.LC4
	call	printk
	addl	$16, %esp
	.loc 1 66 0
	call	init_hash_table
	.loc 1 67 0
	subl	$8, %esp
	pushl	$.LC11
	pushl	$.LC4
	call	printk
	addl	$16, %esp
	.loc 1 69 0
	call	init_proc
	.loc 1 70 0
	subl	$8, %esp
	pushl	$.LC12
	pushl	$.LC4
	call	printk
	addl	$16, %esp
	.loc 1 72 0
	call	intr_enable
	.loc 1 74 0
	call	palloc_pf_test
	.loc 1 76 0
	call	refreshScreen
	.loc 1 80 0
	call	sema_self_test
	.loc 1 81 0
	subl	$12, %esp
	pushl	$.LC13
	call	printk
	addl	$16, %esp
	.loc 1 85 0
	call	refreshScreen
	.loc 1 88 0
	nop
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE19:
	.size	main_init, .-main_init
	.section	.rodata
.LC14:
	.string	"SSUOS main start!!!!\n"
	.align 4
.LC15:
	.string	"          ______    ______   __    __         ______    ______  \n"
	.align 4
.LC16:
	.string	"         /      \\  /      \\ /  |  /  |       /      \\  /      \\ \n"
	.align 4
.LC17:
	.string	"        /$$$$$$  |/$$$$$$  |$$ |  $$ |      /$$$$$$  |/$$$$$$  |\n"
	.align 4
.LC18:
	.string	"        $$ \\__$$/ $$ \\__$$/ $$ |  $$ |      $$ |  $$ |$$ \\__$$/ \n"
	.align 4
.LC19:
	.string	"        $$      \\ $$      \\ $$ |  $$ |      $$ |  $$ |$$      \\ \n"
	.align 4
.LC20:
	.string	"         $$$$$$  | $$$$$$  |$$ |  $$ |      $$ |  $$ | $$$$$$  |\n"
	.align 4
.LC21:
	.string	"        /  \\__$$ |/  \\__$$ |$$ \\__$$ |      $$ \\__$$ |/  \\__$$ |\n"
	.align 4
.LC22:
	.string	"        $$    $$/ $$    $$/ $$    $$/       $$    $$/ $$    $$/ \n"
	.align 4
.LC23:
	.string	"         $$$$$$/   $$$$$$/   $$$$$$/         $$$$$$/   $$$$$$/  \n"
.LC24:
	.string	"\n"
	.align 4
.LC25:
	.string	"****************Made by OSLAB in SoongSil University*********************\n"
	.align 4
.LC26:
	.string	"contributors : Yunkyu Lee  , Minwoo Jang  , Sanghun Choi , Eunseok Choi\n"
	.align 4
.LC27:
	.string	"               Hyunho Ji   , Giwook Kang  , Kisu Kim     , Seonguk Lee \n"
	.align 4
.LC28:
	.string	"               Gibeom Byeon, Jeonghwan Lee, Kyoungmin Kim, Myungjoon Shon\n"
	.align 4
.LC29:
	.string	"               Hansol Lee  , Jinwoo Lee   , Mhanwoo Heo\n"
	.align 4
.LC30:
	.string	"************************  Professor. Jiman Hong  ************************\n"
	.align 4
.LC31:
	.string	"                                                                  \n"
	.text
	.globl	print_contributors
	.type	print_contributors, @function
print_contributors:
.LFB20:
	.loc 1 91 0
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$8, %esp
	.loc 1 92 0
	subl	$8, %esp
	pushl	$.LC14
	pushl	$.LC4
	call	printk
	addl	$16, %esp
	.loc 1 93 0
	subl	$12, %esp
	pushl	$.LC15
	call	printk
	addl	$16, %esp
	.loc 1 94 0
	subl	$12, %esp
	pushl	$.LC16
	call	printk
	addl	$16, %esp
	.loc 1 95 0
	subl	$12, %esp
	pushl	$.LC17
	call	printk
	addl	$16, %esp
	.loc 1 96 0
	subl	$12, %esp
	pushl	$.LC18
	call	printk
	addl	$16, %esp
	.loc 1 97 0
	subl	$12, %esp
	pushl	$.LC19
	call	printk
	addl	$16, %esp
	.loc 1 98 0
	subl	$12, %esp
	pushl	$.LC20
	call	printk
	addl	$16, %esp
	.loc 1 99 0
	subl	$12, %esp
	pushl	$.LC21
	call	printk
	addl	$16, %esp
	.loc 1 100 0
	subl	$12, %esp
	pushl	$.LC22
	call	printk
	addl	$16, %esp
	.loc 1 101 0
	subl	$12, %esp
	pushl	$.LC23
	call	printk
	addl	$16, %esp
	.loc 1 102 0
	subl	$12, %esp
	pushl	$.LC24
	call	printk
	addl	$16, %esp
	.loc 1 103 0
	subl	$12, %esp
	pushl	$.LC25
	call	printk
	addl	$16, %esp
	.loc 1 104 0
	subl	$12, %esp
	pushl	$.LC24
	call	printk
	addl	$16, %esp
	.loc 1 105 0
	subl	$12, %esp
	pushl	$.LC26
	call	printk
	addl	$16, %esp
	.loc 1 106 0
	subl	$12, %esp
	pushl	$.LC27
	call	printk
	addl	$16, %esp
	.loc 1 107 0
	subl	$12, %esp
	pushl	$.LC28
	call	printk
	addl	$16, %esp
	.loc 1 108 0
	subl	$12, %esp
	pushl	$.LC29
	call	printk
	addl	$16, %esp
	.loc 1 109 0
	subl	$12, %esp
	pushl	$.LC24
	call	printk
	addl	$16, %esp
	.loc 1 110 0
	subl	$12, %esp
	pushl	$.LC30
	call	printk
	addl	$16, %esp
	.loc 1 111 0
	subl	$12, %esp
	pushl	$.LC31
	call	printk
	addl	$16, %esp
	.loc 1 112 0
	nop
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE20:
	.size	print_contributors, .-print_contributors
.Letext0:
	.file 2 "./include/type.h"
	.file 3 "./include/mem/hashing.h"
	.file 4 "./include/device/console.h"
	.file 5 "./include/syscall.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x229
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x4
	.uleb128 0x1
	.long	.LASF34
	.byte	0xc
	.long	.LASF35
	.long	.LASF36
	.long	.Ltext0
	.long	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.long	.LASF0
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.long	.LASF1
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.long	.LASF2
	.uleb128 0x2
	.byte	0x8
	.byte	0x5
	.long	.LASF3
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.long	.LASF4
	.uleb128 0x2
	.byte	0x2
	.byte	0x5
	.long	.LASF5
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.string	"int"
	.uleb128 0x4
	.long	.LASF7
	.byte	0x2
	.byte	0x2d
	.long	0x25
	.uleb128 0x2
	.byte	0x2
	.byte	0x7
	.long	.LASF6
	.uleb128 0x4
	.long	.LASF8
	.byte	0x2
	.byte	0x33
	.long	0x33
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.long	.LASF9
	.uleb128 0x5
	.long	.LASF37
	.byte	0x4
	.long	0x33
	.byte	0x5
	.byte	0x4
	.long	0xaf
	.uleb128 0x6
	.long	.LASF10
	.byte	0
	.uleb128 0x6
	.long	.LASF11
	.byte	0x1
	.uleb128 0x6
	.long	.LASF12
	.byte	0x2
	.uleb128 0x6
	.long	.LASF13
	.byte	0x3
	.uleb128 0x6
	.long	.LASF14
	.byte	0x4
	.uleb128 0x6
	.long	.LASF15
	.byte	0x5
	.byte	0
	.uleb128 0x7
	.long	.LASF17
	.byte	0x8
	.byte	0x3
	.byte	0x10
	.long	0xd4
	.uleb128 0x8
	.string	"key"
	.byte	0x3
	.byte	0x11
	.long	0x68
	.byte	0
	.uleb128 0x9
	.long	.LASF16
	.byte	0x3
	.byte	0x12
	.long	0x68
	.byte	0x4
	.byte	0
	.uleb128 0x4
	.long	.LASF17
	.byte	0x3
	.byte	0x13
	.long	0xaf
	.uleb128 0x7
	.long	.LASF18
	.byte	0x24
	.byte	0x3
	.byte	0x15
	.long	0x104
	.uleb128 0x9
	.long	.LASF19
	.byte	0x3
	.byte	0x17
	.long	0x104
	.byte	0
	.uleb128 0x9
	.long	.LASF20
	.byte	0x3
	.byte	0x18
	.long	0x11b
	.byte	0x4
	.byte	0
	.uleb128 0xa
	.long	0x56
	.long	0x114
	.uleb128 0xb
	.long	0x114
	.byte	0x3
	.byte	0
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.long	.LASF21
	.uleb128 0xa
	.long	0xd4
	.long	0x12b
	.uleb128 0xb
	.long	0x114
	.byte	0x3
	.byte	0
	.uleb128 0x4
	.long	.LASF18
	.byte	0x3
	.byte	0x19
	.long	0xdf
	.uleb128 0xc
	.long	.LASF22
	.value	0x3600
	.byte	0x3
	.byte	0x1b
	.long	0x15d
	.uleb128 0x9
	.long	.LASF23
	.byte	0x3
	.byte	0x1c
	.long	0x15d
	.byte	0
	.uleb128 0xd
	.long	.LASF24
	.byte	0x3
	.byte	0x1d
	.long	0x16d
	.value	0x2400
	.byte	0
	.uleb128 0xa
	.long	0x12b
	.long	0x16d
	.uleb128 0xb
	.long	0x114
	.byte	0xff
	.byte	0
	.uleb128 0xa
	.long	0x12b
	.long	0x17d
	.uleb128 0xb
	.long	0x114
	.byte	0x7f
	.byte	0
	.uleb128 0x4
	.long	.LASF22
	.byte	0x3
	.byte	0x1e
	.long	0x136
	.uleb128 0xe
	.long	.LASF25
	.byte	0x1
	.byte	0x1b
	.long	.LFB18
	.long	.LFE18-.LFB18
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0xe
	.long	.LASF26
	.byte	0x1
	.byte	0x24
	.long	.LFB19
	.long	.LFE19-.LFB19
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0xe
	.long	.LASF27
	.byte	0x1
	.byte	0x5a
	.long	.LFB20
	.long	.LFE20-.LFB20
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0xf
	.long	.LASF28
	.byte	0x4
	.byte	0xc
	.long	0x4f
	.uleb128 0x5
	.byte	0x3
	.long	Glob_x
	.uleb128 0xf
	.long	.LASF29
	.byte	0x4
	.byte	0xd
	.long	0x4f
	.uleb128 0x5
	.byte	0x3
	.long	Glob_y
	.uleb128 0xf
	.long	.LASF30
	.byte	0x3
	.byte	0x20
	.long	0x17d
	.uleb128 0x5
	.byte	0x3
	.long	hash_table
	.uleb128 0xf
	.long	.LASF31
	.byte	0x1
	.byte	0x17
	.long	0x1ff
	.uleb128 0x5
	.byte	0x3
	.long	VERSION
	.uleb128 0x10
	.byte	0x4
	.long	0x205
	.uleb128 0x11
	.long	0x2c
	.uleb128 0xf
	.long	.LASF32
	.byte	0x1
	.byte	0x18
	.long	0x1ff
	.uleb128 0x5
	.byte	0x3
	.long	AUTHOR
	.uleb128 0xf
	.long	.LASF33
	.byte	0x1
	.byte	0x19
	.long	0x1ff
	.uleb128 0x5
	.byte	0x3
	.long	MODIFIER
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x10
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0x4
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0x5
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xd
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0x5
	.byte	0
	.byte	0
	.uleb128 0xe
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x10
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.long	0x1c
	.value	0x2
	.long	.Ldebug_info0
	.byte	0x4
	.byte	0
	.value	0
	.value	0
	.long	.Ltext0
	.long	.Letext0-.Ltext0
	.long	0
	.long	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF22:
	.string	"level_hash"
.LASF12:
	.string	"SYS_WAIT"
.LASF5:
	.string	"short int"
.LASF21:
	.string	"sizetype"
.LASF15:
	.string	"SYS_NUM"
.LASF16:
	.string	"value"
.LASF7:
	.string	"uint8_t"
.LASF14:
	.string	"SYS_SHUTDOWN"
.LASF27:
	.string	"print_contributors"
.LASF3:
	.string	"long long int"
.LASF36:
	.string	"/home/hkkim/semester3-2/oslab/ssuos/src/kernel"
.LASF26:
	.string	"main_init"
.LASF32:
	.string	"AUTHOR"
.LASF31:
	.string	"VERSION"
.LASF10:
	.string	"SYS_FORK"
.LASF19:
	.string	"token"
.LASF17:
	.string	"entry"
.LASF0:
	.string	"unsigned char"
.LASF25:
	.string	"ssuos_main"
.LASF35:
	.string	"arch/Main.c"
.LASF4:
	.string	"signed char"
.LASF9:
	.string	"long long unsigned int"
.LASF8:
	.string	"uint32_t"
.LASF2:
	.string	"unsigned int"
.LASF20:
	.string	"slot"
.LASF6:
	.string	"short unsigned int"
.LASF1:
	.string	"char"
.LASF13:
	.string	"SYS_SSUREAD"
.LASF33:
	.string	"MODIFIER"
.LASF23:
	.string	"top_buckets"
.LASF11:
	.string	"SYS_EXIT"
.LASF34:
	.string	"GNU C11 5.4.0 20160609 -m32 -mtune=generic -march=i686 -g -O0 -ffreestanding -fno-stack-protector"
.LASF24:
	.string	"bottom_buckets"
.LASF18:
	.string	"level_bucket"
.LASF28:
	.string	"Glob_x"
.LASF29:
	.string	"Glob_y"
.LASF37:
	.string	"SYS_LIST"
.LASF30:
	.string	"hash_table"
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.11) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits

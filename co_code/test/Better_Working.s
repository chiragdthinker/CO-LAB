section .text
 BITS 32 
; shifting to real mode
	  mov byte [0x1009],0xbf
	  mov byte [0x100e],0x40
	   mov byte [0x1011],0xbf
	 mov byte [0x1016],0x40
	 mov ax,0x10
	  mov ds,ax
	  mov ss,ax
	  mov es,ax
	  mov gs,ax
	  mov fs,ax
	 jmp 0x8:cnk_next
 cnk_next:
	 mov eax,cr0
	 and eax,0xfffffffe
	  mov cr0,eax
; 1. Registers ..
	  mov ax,0xb00
	  mov ds,ax
	  mov ss,ax
	  mov es,ax
	  mov gs,ax
	  mov fs,ax
	  jmp 0xa00:0


 Chan_Start_Real: 
section .kama 
 BITS 32 
 code_base EQU 0xa000  
 ;Storing the Previous IDTR 
SIDT [0x2ff2] 
; IP = 0x0000
 ;Initializing Test Status Bytes 1 and 2 to 0xdead 
 mov word [0x2200], 0xdead; IP = 0x0007
 ;Initializing Exception Counter to 0x0000 
 mov word [0x2ff8], 0x0; IP = 0x0010
	LIDT [0x220A]; IP = 0x0019
 ; Initializing Flags
	 mov dword [0x1ff0], 0x0; IP = 0x0020
	 mov esp, 0x1ff0; IP = 0x002a
	 popfd ; IP = 0x002f
 start:
	  mov ax,0xb32
	  mov es,ax
	  mov ax,0xbc8
	  mov fs,ax
	  mov ax,0xc5e
	  mov gs,ax
;---------------------YOUR CODE BEGINS HERE---------------------------------
;Ajay, Krishnan, Sanjay
mov edi,0x0		;Initialising first loop var(edi) to 0
L1:
	mov esp,0xa		
	cmp edi,esp		;exit if edi is 10
	je L4
	mov ebx,0x0		;Initialising second loop var(ebx) to 0
	L2:
		mov esp,0x1e		;exit if ebx is 30
		cmp ebx,esp
		je L5
		
	;memory address of the C[edi][ebx] element stored in esi
	;mov esi, 0x15e0+(edi*0x1E+ebx)*0x8
		
		mov esi,edi
		mov eax,0x1e	
		imul esi;
		mov esi,eax
		add esi,ebx
		mov eax,0x8
		imul esi;
		mov esi,eax
		mov esp,0x15e0
		add esi,esp
		
		
		mov esp,0x0		;Setting C[edi][ebx] to 0
		mov [esi],esp
		mov [esi+0x4],esp
		mov ecx,0x0		;Initialising third loop var(ecx) to 0
		L3:
			mov esp,0x14		;exit if ecx is 20
			cmp ecx,esp
			je L6
	
		;storing B[ecx][ebx] element in esp
        ;mov esp,(0x1E*ecx+ebx)*0x4+0x320
            
            mov esi,ecx		
            mov eax,0x1e
       		imul esi;
			mov esi,eax
			add esi,ebx
			mov eax,0x4
			imul esi;
			mov esi,eax
			add esi,0x320
			mov esp,[esi]
		
		;storing A[edi][ecx] value in eax
		;mov esi,(0x14*edi+ecx)*0x4
			
			mov esi,edi		
			mov edx,0x14
			mov eax,edx
			imul esi;
			mov esi,eax
			add esi,ecx
			mov eax,0x4
			imul esi;
			mov esi,eax
			mov eax,[esi]			
			
			;multiplying eax and esp which will be stored in edx:eax
			imul esp
            
            ;getting the first 4 bytes of C[edi][ebx] and storing in esp
            	;mov esi,0x15e0+(0x1E*edi+ebx)*0x8+0x4
            mov esi,edi

			shl esi,2	;imul esi, 0x1E
			add esi,edi
			add esi,edi
			add esi,edi
			shl esi,2
			add esi,edi
			add esi,edi
			
			add esi,ebx
			
			shl esi,3	;imul esi,0x8		
			
			add esi,0x15e0
			mov esp,[esi]

			;getting the last 4 bytes of C[edi][ebx] --- esi should be incresed by 4 

			;adding eax:edx to [esi+4]:esp
			add eax,esp
			adc edx,[esi+0x4]

			
			;moving the last 4 bytes (lsb) after addition
			;mov esi,0xC80+(0x1E*edi+ebx)*0x8+0x4
			mov [esi],eax
	        
	        ;moving the first 4 bytes (msb) after addition
	        ;mov esi,0xC80+(0x1E*edi+ebx)*0x8
			mov [esi+0x4],edx
			
			add ecx,0x1
			jmp L3
		L6:
			add ebx,0x1
			jmp L2
	L5:
		add edi,0x1
		jmp L1
L4:

;--------------------YOUR CODE ENDS HERE----------------
 chanHappy:
;Dumping General Purpose Registers in Memory
;Comparing Exception counter with actual number of induced exceptions
	 clts; IP = 0x0718
	 mov word [0x2208],0xdece; IP = 0x071a
	 cmp word [0x2ff8], 0; IP = 0x0723
	jne near chanSad; IP = 0x072c
 HLT_L: mov word [0x2200], 0xbabe; IP = 0x072e
 Chan_End_Real:
;Start of X86 GDB specific section for displaying result on Postcard 
	 mov word [0x2208],0xcafe
	mov	al, 0xbb
	jmp	bulb
 chanSad:
	mov	al, 0xff
 bulb:
	mov	edx, 0x0080
;	out	dx, al
	mov	edx, 0x2fffff
 delay:
	dec	edx
	jnz	delay
;Restoring the previous IDTR 
	LIDT [0x2ff2]
;Restoring the Segment definitions specific to X86 GDBs  
;for proper execution of int 3 
	 mov ax,0
	 	 mov ds,ax
	     mov byte [0x1009],0xff
	     mov byte [0x100e],0x4f
	     mov byte [0x1011],0xff
	     mov byte [0x1016],0xcf
	 mov eax,cr0
	  or eax,0x1
	  mov cr0,eax
	  mov ax,0x10
	 mov ds,ax
	 mov ss,ax
	 mov es,ax
	 mov gs,ax
	 mov fs,ax
	 mov ESP, 0x8000
	 mov EBP, 0x9000
	 jmp 0x8:dword fin
 BITS 32
	 fin: clts
 int 3
 Chan_Test_End:
 
  align 0x1000
;-----------------------YOUR DATA BEGINS HERE------

dd 0x17
dd 0x18
dd 0x1f
dd 0x32
dd 0x57
dd 0x94
dd 0xef
dd 0x16e
dd 0x217
dd 0x2f0
dd 0xdf
dd 0x22a
dd 0x97
dd 0x26c
dd 0x16f
dd 0xc6
dd 0x77
dd 0x88
dd 0xff
dd 0x1e2
dd 0x17
dd 0x1e4
dd 0x10f
dd 0xbe
dd 0xf7
dd 0x1c0
dd 0x31f
dd 0x1fa
dd 0x177
dd 0x19c
dd 0x26f
dd 0xd6
dd 0x317
dd 0x2f8
dd 0x7f
dd 0x1f2
dd 0x117
dd 0x114
dd 0x1ef
dd 0x8e
dd 0x17
dd 0x90
dd 0x1ff
dd 0x14a
dd 0x197
dd 0x2ec
dd 0x22f
dd 0x286
dd 0xd7
dd 0x48
dd 0xdf
dd 0x2a2
dd 0x277
dd 0x64
dd 0x2af
dd 0x31e
dd 0x1b7
dd 0x1a0
dd 0x2df
dd 0x25a
dd 0x17
dd 0x25c
dd 0x2ef
dd 0x1d6
dd 0x237
dd 0xf8
dd 0x13f
dd 0x312
dd 0x37
dd 0x214
dd 0x26f
dd 0x14e
dd 0x1d7
dd 0xf0
dd 0x1bf
dd 0x12a
dd 0x257
dd 0x22c
dd 0xaf
dd 0x106
dd 0x17
dd 0x108
dd 0xbf
dd 0x262
dd 0x2d7
dd 0x224
dd 0x4f
dd 0x7e
dd 0x2b7
dd 0xc0
dd 0xdf
dd 0x31a
dd 0x137
dd 0x17c
dd 0xcf
dd 0x256
dd 0x2f7
dd 0x2b8
dd 0x19f
dd 0x2d2
dd 0x17
dd 0x2d4
dd 0x1af
dd 0x2ee
dd 0x57
dd 0x30
dd 0x27f
dd 0x10a
dd 0x217
dd 0x28c
dd 0x26f
dd 0x1c6
dd 0x97
dd 0x208
dd 0x2ff
dd 0x62
dd 0x77
dd 0x24
dd 0x28f
dd 0x17e
dd 0x17
dd 0x180
dd 0x29f
dd 0x5a
dd 0xf7
dd 0x15c
dd 0x18f
dd 0x196
dd 0x177
dd 0x138
dd 0xdf
dd 0x72
dd 0x317
dd 0x294
dd 0x20f
dd 0x18e
dd 0x117
dd 0xb0
dd 0x5f
dd 0x2a
dd 0x17
dd 0x2c
dd 0x6f
dd 0xe6
dd 0x197
dd 0x288
dd 0x9f
dd 0x222
dd 0xd7
dd 0x304
dd 0x26f
dd 0x23e
dd 0x277
dd 0x320
dd 0x11f
dd 0x2ba
dd 0x1b7
dd 0x13c
dd 0x14f
dd 0x1f6
dd 0x17
dd 0x1f8
dd 0x15f
dd 0x172
dd 0x237
dd 0x94
dd 0x2cf
dd 0x2ae
dd 0x37
dd 0x1b0
dd 0xdf
dd 0xea
dd 0x1d7
dd 0x8c
dd 0x2f
dd 0xc6
dd 0x257
dd 0x1c8
dd 0x23f
dd 0xa2
dd 0x17
dd 0xa4
dd 0x24f
dd 0x1fe
dd 0x2d7
dd 0x1c0
dd 0x1df
dd 0x1a
dd 0x2b7
dd 0x5c
dd 0x26f
dd 0x2b6
dd 0x137
dd 0x118
dd 0x25f
dd 0x1f2
dd 0x2f7
dd 0x254
dd 0x32f
dd 0x26e
dd 0x17
dd 0x270
dd 0x1f
dd 0x28a
dd 0x57
dd 0x2ec
dd 0xef
dd 0xa6
dd 0x217
dd 0x228
dd 0xdf
dd 0x162
dd 0x97
dd 0x1a4
dd 0x16f
dd 0x31e
dd 0x77
dd 0x2e0
dd 0xff
dd 0x11a
dd 0x17
dd 0x11c
dd 0x10f
dd 0x316
dd 0xf7
dd 0xf8
dd 0x31f
dd 0x132
dd 0x177
dd 0xd4
dd 0x26f
dd 0x32e
dd 0x317
dd 0x230
dd 0x7f
dd 0x12a
dd 0x117
dd 0x4c
dd 0x1ef
dd 0x2e6
dd 0x17
dd 0x2e8
dd 0x1ff
dd 0x82
dd 0x197
dd 0x224
dd 0x22f
dd 0x1be
dd 0xd7
dd 0x2a0
dd 0xdf
dd 0x1da
dd 0x277
dd 0x2bc
dd 0x2af
dd 0x256
dd 0x1b7
dd 0xd8
dd 0x2df
dd 0x192
dd 0x17
dd 0x194
dd 0x2ef
dd 0x10e
dd 0x237
dd 0x30
dd 0x13f
dd 0x24a
dd 0x37
dd 0x14c
dd 0x26f
dd 0x86
dd 0x1d7
dd 0x28
dd 0x1bf
dd 0x62
dd 0x257
dd 0x164
dd 0xaf
dd 0x3e
dd 0x17
dd 0x40
dd 0xbf
dd 0x19a
dd 0x2d7
dd 0x15c
dd 0x4f
dd 0x2d6
dd 0x2b7
dd 0x318
dd 0xdf
dd 0x252
dd 0x137
dd 0xb4
dd 0xcf
dd 0x18e
dd 0x2f7
dd 0x1f0
dd 0x19f
dd 0x20a
dd 0x17
dd 0x20c
dd 0x1af
dd 0x226
dd 0x57
dd 0x288
dd 0x27f
dd 0x42
dd 0x217
dd 0x1c4
dd 0x26f
dd 0xfe
dd 0x97
dd 0x140
dd 0x2ff
dd 0x2ba
dd 0x77
dd 0x27c
dd 0x28f
dd 0xb6
dd 0x17
dd 0xb8
dd 0x29f
dd 0x2b2
dd 0xf7
dd 0x94
dd 0x18f
dd 0xce
dd 0x177
dd 0x70
dd 0xdf
dd 0x2ca
dd 0x317
dd 0x1cc
dd 0x20f
dd 0xc6
dd 0x117
dd 0x308
dd 0x5f
dd 0x282
dd 0x17
dd 0x284
dd 0x6f
dd 0x1e
dd 0x197
dd 0x1c0
dd 0x9f
dd 0x15a
dd 0xd7
dd 0x23c
dd 0x26f
dd 0x176
dd 0x277
dd 0x258
dd 0x11f
dd 0x1f2
dd 0x1b7
dd 0x74
dd 0x14f
dd 0x12e
dd 0x17
dd 0x130
dd 0x15f
dd 0xaa
dd 0x237
dd 0x2ec
dd 0x2cf
dd 0x1e6
dd 0x37
dd 0xe8
dd 0xdf
dd 0x22
dd 0x1d7
dd 0x2e4
dd 0x2f
dd 0x31e
dd 0x257
dd 0x100
dd 0x23f
dd 0x2fa
dd 0x17
dd 0x2fc
dd 0x24f
dd 0x136
dd 0x2d7
dd 0xf8
dd 0x1df
dd 0x272
dd 0x2b7
dd 0x2b4
dd 0x26f
dd 0x1ee
dd 0x137
dd 0x50
dd 0x25f
dd 0x12a
dd 0x2f7
dd 0x18c
dd 0x32f
dd 0x1a6
dd 0x17
dd 0x1a8
dd 0x1f
dd 0x1c2
dd 0x57
dd 0x224
dd 0xef
dd 0x2fe
dd 0x217
dd 0x160
dd 0xdf
dd 0x9a
dd 0x97
dd 0xdc
dd 0x16f
dd 0x256
dd 0x77
dd 0x218
dd 0xff
dd 0x52
dd 0x17
dd 0x54
dd 0x10f
dd 0x24e
dd 0xf7
dd 0x30
dd 0x31f
dd 0x6a
dd 0x177
dd 0x32c
dd 0x26f
dd 0x266
dd 0x317
dd 0x168
dd 0x7f
dd 0x62
dd 0x117
dd 0x2a4
dd 0x1ef
dd 0x21e
dd 0x17
dd 0x220
dd 0x1ff
dd 0x2da
dd 0x197
dd 0x15c
dd 0x22f
dd 0xf6
dd 0xd7
dd 0x1d8
dd 0xdf
dd 0x112
dd 0x277
dd 0x1f4
dd 0x2af
dd 0x18e
dd 0x1b7
dd 0x330
dd 0x2df
dd 0xca
dd 0x17
dd 0xcc
dd 0x2ef
dd 0x46
dd 0x237
dd 0x288
dd 0x13f
dd 0x182
dd 0x37
dd 0x84
dd 0x26f
dd 0x2de
dd 0x1d7
dd 0x280
dd 0x1bf
dd 0x2ba
dd 0x257
dd 0x9c
dd 0xaf
dd 0x296
dd 0x17
dd 0x298
dd 0xbf
dd 0xd2
dd 0x2d7
dd 0x94
dd 0x4f
dd 0x20e
dd 0x2b7
dd 0x250
dd 0xdf
dd 0x18a
dd 0x137
dd 0x30c
dd 0xcf
dd 0xc6
dd 0x2f7
dd 0x128
dd 0x19f
dd 0x142
dd 0x17
dd 0x144
dd 0x1af
dd 0x15e
dd 0x57
dd 0x1c0
dd 0x27f
dd 0x29a
dd 0x217
dd 0xfc
dd 0x26f
dd 0x36
dd 0x97
dd 0x78
dd 0x2ff
dd 0x1f2
dd 0x77
dd 0x1b4
dd 0x28f
dd 0x30e
dd 0x17
dd 0x310
dd 0x29f
dd 0x1ea
dd 0xf7
dd 0x2ec
dd 0x18f
dd 0x326
dd 0x177
dd 0x2c8
dd 0xdf
dd 0x202
dd 0x317
dd 0x104
dd 0x20f
dd 0x31e
dd 0x117
dd 0x240
dd 0x5f
dd 0x1ba
dd 0x17
dd 0x1bc
dd 0x6f
dd 0x276
dd 0x197
dd 0xf8
dd 0x9f
dd 0x92
dd 0xd7
dd 0x174
dd 0x26f
dd 0xae
dd 0x277
dd 0x190
dd 0x11f
dd 0x12a
dd 0x1b7
dd 0x2cc
dd 0x14f
dd 0x66
dd 0x17
dd 0x68
dd 0x15f
dd 0x302
dd 0x237
dd 0x224
dd 0x2cf
dd 0x11e
dd 0x37
dd 0x20
dd 0xdf
dd 0x27a
dd 0x1d7
dd 0x21c
dd 0x2f
dd 0x256
dd 0x257
dd 0x38
dd 0x23f
dd 0x232
dd 0x17
dd 0x234
dd 0x24f
dd 0x6e
dd 0x2d7
dd 0x30
dd 0x1df
dd 0x1aa
dd 0x2b7
dd 0x1ec
dd 0x26f
dd 0x126
dd 0x137
dd 0x2a8
dd 0x25f
dd 0x62
dd 0x2f7
dd 0xc4
dd 0x32f
dd 0xde
dd 0x17
dd 0xe0
dd 0x1f
dd 0xfa
dd 0x57
dd 0x15c
dd 0xef
dd 0x236
dd 0x217
dd 0x98
dd 0xdf
dd 0x2f2
dd 0x97
dd 0x334
dd 0x16f
dd 0x18e
dd 0x77
dd 0x150
dd 0xff
dd 0x2aa
dd 0x17
dd 0x2ac
dd 0x10f
dd 0x186
dd 0xf7
dd 0x288
dd 0x31f
dd 0x2c2
dd 0x177
dd 0x264
dd 0x26f
dd 0x19e
dd 0x317
dd 0xa0
dd 0x7f
dd 0x2ba
dd 0x117
dd 0x1dc
dd 0x1ef
dd 0x156
dd 0x17
dd 0x158
dd 0x1ff
dd 0x212
dd 0x197
dd 0x94
dd 0x22f
dd 0x2e
dd 0xd7
dd 0x110
dd 0xdf
dd 0x4a
dd 0x277
dd 0x12c
dd 0x2af
dd 0xc6
dd 0x1b7
dd 0x268
dd 0x2df
dd 0x322
dd 0x17
dd 0x324
dd 0x2ef
dd 0x29e
dd 0x237
dd 0x1c0
dd 0x13f
dd 0xba
dd 0x37
dd 0x2dc
dd 0x26f
dd 0x216
dd 0x1d7
dd 0x1b8
dd 0x1bf
dd 0x1f2
dd 0x257
dd 0x2f4
dd 0xaf
dd 0x1ce
dd 0x17
dd 0x1d0
dd 0xbf
dd 0x32a
dd 0x2d7
dd 0x2ec
dd 0x4f
dd 0x146
dd 0x2b7
dd 0x188
dd 0xdf
dd 0xc2
dd 0x137
dd 0x244
dd 0xcf
dd 0x31e
dd 0x2f7
dd 0x60
dd 0x19f
dd 0x7a
dd 0x17
dd 0x7c
dd 0x1af
dd 0x96
dd 0x57
dd 0xf8
dd 0x27f
dd 0x1d2
dd 0x217
dd 0x34
dd 0x26f
dd 0x28e
dd 0x97
dd 0x2d0
dd 0x2ff
dd 0x12a
dd 0x77
dd 0xec
dd 0x28f
dd 0x246
dd 0x17
dd 0x248
dd 0x29f
dd 0x122
dd 0xf7
dd 0x224
dd 0x18f
dd 0x25e
dd 0x177
dd 0x200
dd 0xdf
dd 0x13a
dd 0x317
dd 0x3c
dd 0x20f
dd 0x256
dd 0x117
dd 0x178
dd 0x5f
dd 0xf2
dd 0x17
dd 0xf4
dd 0x6f
dd 0x1ae
dd 0x197
dd 0x30
dd 0x9f
dd 0x2ea
dd 0xd7
dd 0xac
dd 0x26f
dd 0x306
dd 0x277
dd 0xc8
dd 0x11f
dd 0x62
dd 0x1b7
dd 0x204
dd 0x14f
dd 0x2be
dd 0x17
dd 0x2c0
dd 0x15f
dd 0x23a
dd 0x237
dd 0x15c
dd 0x2cf
dd 0x56
dd 0x37
dd 0x278
dd 0xdf
dd 0x1b2
dd 0x1d7
dd 0x154
dd 0x2f
dd 0x18e
dd 0x257
dd 0x290
dd 0x23f
dd 0x16a
dd 0x17
dd 0x16c
dd 0x24f
dd 0x2c6
dd 0x2d7
dd 0x288
dd 0x1df
dd 0xe2
dd 0x2b7
dd 0x124
dd 0x26f
dd 0x5e
dd 0x137
dd 0x1e0
dd 0x25f
dd 0x2ba
dd 0x2f7
dd 0x31c
dd 0x32f
dd 0x336
dq 0x164c20
dq 0x259f90
dq 0x23aaf0
dq 0x2874e0
dq 0x22bb40
dq 0x24e410
dq 0x28ded0
dq 0x229fc0
dq 0x2027e0
dq 0x2226d0
dq 0xee1b0
dq 0x222360
dq 0x1ee9c0
dq 0x1f9ff0
dq 0x24d650
dq 0x1ebb80
dq 0x1e15e0
dq 0x220830
dq 0x2944b0
dq 0x237080
dq 0x161d40
dq 0x210250
dq 0x24bdf0
dq 0x275ba0
dq 0x1de8e0
dq 0x20f5d0
dq 0x263bd0
dq 0x267b40
dq 0x1df880
dq 0x233070
dq 0x1d5038
dq 0x31ed90
dq 0x361c08
dq 0x3d3d30
dq 0x3745d8
dq 0x2cd670
dq 0x3893e8
dq 0x31a1f0
dq 0x3428f8
dq 0x2f4310
dq 0x1d38c8
dq 0x35eb70
dq 0x3060d8
dq 0x283b10
dq 0x315268
dq 0x3115f0
dq 0x38c778
dq 0x2ea130
dq 0x36ecc8
dq 0x3af4d0
dq 0x183f58
dq 0x387bb0
dq 0x34be08
dq 0x363850
dq 0x2f8578
dq 0x349090
dq 0x318be8
dq 0x3b0b50
dq 0x32f398
dq 0x3a3f90
dq 0x1a0090
dq 0x361410
dq 0x3d0d60
dq 0x3d8380
dq 0x3c04b0
dq 0x374650
dq 0x39a940
dq 0x41b720
dq 0x353e50
dq 0x35f9d0
dq 0x213c20
dq 0x3e5f80
dq 0x421030
dq 0x3579b0
dq 0x35d2c0
dq 0x3af160
dq 0x42e550
dq 0x2e62b0
dq 0x339d20
dq 0x3f2320
dq 0x2395b0
dq 0x32ce90
dq 0x3d2660
dq 0x36ec00
dq 0x373250
dq 0x3991d0
dq 0x3ddc40
dq 0x437f60
dq 0x38eaf0
dq 0x3fae30
dq 0x1d7428
dq 0x384cd0
dq 0x38fbf8
dq 0x3cb090
dq 0x355cc8
dq 0x34f170
dq 0x3565d8
dq 0x357410
dq 0x328ae8
dq 0x32c0d0
dq 0x1d5cb8
dq 0x358450
dq 0x3728c8
dq 0x2c6190
dq 0x31da58
dq 0x345e90
dq 0x3bf268
dq 0x2d6270
dq 0x335ab8
dq 0x3d8830
dq 0x1d4548
dq 0x3380b0
dq 0x3991f8
dq 0x331b70
dq 0x347268
dq 0x343f50
dq 0x3245d8
dq 0x3fb830
dq 0x3a1f88
dq 0x39b610
dq 0x1ebea0
dq 0x3784d0
dq 0x3ba470
dq 0x436f20
dq 0x3811c0
dq 0x350750
dq 0x377850
dq 0x349e00
dq 0x37d660
dq 0x356a10
dq 0x14e330
dq 0x3c55a0
dq 0x3e3640
dq 0x392330
dq 0x35c7d0
dq 0x3d07c0
dq 0x39de60
dq 0x328f70
dq 0x32ca30
dq 0x3730c0
dq 0x2371c0
dq 0x2d0b90
dq 0x3ac370
dq 0x2ecde0
dq 0x382160
dq 0x3ec510
dq 0x38bd50
dq 0x3f4f80
dq 0x32b900
dq 0x3579b0
dq 0x1adf38
dq 0x3e8050
dq 0x371608
dq 0x354df0
dq 0x2d04d8
dq 0x2fa530
dq 0x3d75e8
dq 0x3858b0
dq 0x2fc3f8
dq 0x36f3d0
dq 0x221ac8
dq 0x35cc30
dq 0x32d1d8
dq 0x252dd0
dq 0x324c68
dq 0x30f6b0
dq 0x336878
dq 0x3075f0
dq 0x3bcec8
dq 0x37e790
dq 0x1ab058
dq 0x328070
dq 0x31d008
dq 0x3afb10
dq 0x35de78
dq 0x366550
dq 0x3285e8
dq 0x37fe10
dq 0x337098
dq 0x344450
dq 0x16b7f0
dq 0x295bd0
dq 0x2e3ec0
dq 0x33bf80
dq 0x2e9410
dq 0x260390
dq 0x30e8a0
dq 0x277ea0
dq 0x2705b0
dq 0x270290
dq 0x191180
dq 0x29f680
dq 0x2b7190
dq 0x2099f0
dq 0x247a20
dq 0x29cde0
dq 0x2f66b0
dq 0x265a70
dq 0x2a4680
dq 0x2a6f20
dq 0x11a710
dq 0x29bfd0
dq 0x2b69c0
dq 0x2af580
dq 0x2abbb0
dq 0x261c90
dq 0x2675a0
dq 0x2dea60
dq 0x2bac50
dq 0x2f7e70
dq 0x225628
dq 0x30bb50
dq 0x3784f8
dq 0x405a10
dq 0x3750c8
dq 0x3723f0
dq 0x3cb8d8
dq 0x343b90
dq 0x3578e8
dq 0x301150
dq 0x1609b8
dq 0x3739d0
dq 0x3246c8
dq 0x327c10
dq 0x354558
dq 0x361410
dq 0x342268
dq 0x2e9af0
dq 0x35cbb8
dq 0x3c4fb0
dq 0x222748
dq 0x36ad30
dq 0x3914f8
dq 0x39b2f0
dq 0x2e9668
dq 0x3577d0
dq 0x3a92d8
dq 0x3e7fb0
dq 0x334988
dq 0x3ce290
dq 0x16dbe0
dq 0x2ec110
dq 0x2d36b0
dq 0x342ce0
dq 0x309300
dq 0x293c90
dq 0x27de90
dq 0x2c4ac0
dq 0x2b43a0
dq 0x298650
dq 0x193570
dq 0x325960
dq 0x2e5180
dq 0x25ba70
dq 0x28ea10
dq 0x283480
dq 0x3679a0
dq 0x2615b0
dq 0x2c9070
dq 0x35cc80
dq 0x16ad00
dq 0x2d8ed0
dq 0x2c55b0
dq 0x28d2a0
dq 0x29cca0
dq 0x2aad50
dq 0x2b1790
dq 0x339140
dq 0x2ef040
dq 0x2dfaf0
dq 0x18fdf8
dq 0x3f3590
dq 0x419bc8
dq 0x473fb0
dq 0x3e4798
dq 0x374970
dq 0x3f63a8
dq 0x435b70
dq 0x3c56b8
dq 0x3ac910
dq 0x278c88
dq 0x4083f0
dq 0x469e98
dq 0x366410
dq 0x3d3628
dq 0x40a970
dq 0x409138
dq 0x3abd30
dq 0x3c2c88
dq 0x3def50
dq 0x1db118
dq 0x35a6b0
dq 0x3e49c8
dq 0x35f9d0
dq 0x3e5738
dq 0x446290
dq 0x3e37a8
dq 0x466bd0
dq 0x373958
dq 0x3f6c90

;--------------------------YOUR DATE ENDS HERE --------
align 0x1000
 ;Chanix Control Page
;Empty space in third page filled with Random data
 db 0x7e
 db 0x10
 db 0x1b
 db 0xee
 db 0x17
 db 0xf8
 db 0x8d
 db 0x50
 db 0xe
 db 0x12
 db 0x8e
 db 0x1a
 db 0x63
 db 0x9d
 db 0xd6
 db 0x74
 db 0x45
 db 0x1e
 db 0x3b
 db 0x72
 db 0x19
 db 0xac
 db 0xb
 db 0xbb
 db 0xce
 db 0xa0
 db 0xf6
 db 0xf8
 db 0x1b
 db 0x1e
 db 0xb1
 db 0x9a
 db 0x2e
 db 0xcc
 db 0x88
 db 0x45
 db 0xc5
 db 0x15
 db 0x96
 db 0xd3
 db 0x28
 db 0x24
 db 0xed
 db 0x8b
 db 0xc2
 db 0xc3
 db 0xff
 db 0x7
 db 0xe1
 db 0x3a
 db 0x79
 db 0xfb
 db 0xe7
 db 0x84
 db 0xb6
 db 0xb5
 db 0x24
 db 0xad
 db 0xad
 db 0x40
 db 0xcb
 db 0x5f
 db 0xda
 db 0xfa
 db 0x2b
 db 0x62
 db 0x3f
 db 0xf0
 db 0x78
 db 0xd5
 db 0xc3
 db 0xa0
 db 0xfa
 db 0xb0
 db 0x2b
 db 0xbc
 db 0x74
 db 0x2a
 db 0xc3
 db 0x55
 db 0x64
 db 0x3c
 db 0x50
 db 0x4b
 db 0xc0
 db 0x7
 db 0x0
 db 0xe4
 db 0xb4
 db 0xae
 db 0x24
 db 0x7f
 db 0xd
 db 0xfe
 db 0x79
 db 0x38
 db 0x61
 db 0xb9
 db 0x29
 db 0xd9
 db 0x8e
 db 0xec
 db 0x79
 db 0x88
 db 0x9d
 db 0xa4
 db 0x44
 db 0x11
 db 0xce
 db 0x7
 db 0x66
 db 0x32
 db 0x43
 db 0xb7
 db 0x7e
 db 0x3
 db 0xbe
 db 0x7e
 db 0xe8
 db 0x72
 db 0x2c
 db 0xc
 db 0xf1
 db 0x39
 db 0xb
 db 0x6b
 db 0x72
 db 0x6c
 db 0x24
 db 0x9b
 db 0x45
 db 0xb2
 db 0x87
 db 0xbe
 db 0x3b
 db 0x24
 db 0x62
 db 0x7f
 db 0x35
 db 0x30
 db 0x87
 db 0x9c
 db 0x62
 db 0xca
 db 0x53
 db 0xe0
 db 0xce
 db 0x11
 db 0x5f
 db 0xb6
 db 0x83
 db 0x8b
 db 0xc2
 db 0x74
 db 0xc5
 db 0xcd
 db 0xdf
 db 0x37
 db 0x39
 db 0x3
 db 0xd2
 db 0x7e
 db 0xb6
 db 0x59
 db 0x3c
 db 0xf1
 db 0x7e
 db 0x9e
 db 0x70
 db 0xb3
 db 0xce
 db 0xf7
 db 0x4f
 db 0x31
 db 0xc2
 db 0xa2
 db 0x11
 db 0x90
 db 0xb3
 db 0x70
 db 0x46
 db 0x36
 db 0xfc
 db 0x8
 db 0xab
 db 0xc1
 db 0xd6
 db 0x8a
 db 0xf8
 db 0xf
 db 0x8e
 db 0xca
 db 0x8e
 db 0x44
 db 0x23
 db 0xca
 db 0x35
 db 0xa1
 db 0x69
 db 0xa5
 db 0x55
 db 0x37
 db 0x9d
 db 0xa4
 db 0x68
 db 0x5f
 db 0x47
 db 0x7a
 db 0xef
 db 0xfa
 db 0xea
 db 0x35
 db 0x31
 db 0xe6
 db 0x3d
 db 0xdc
 db 0xa7
 db 0x13
 db 0x66
 db 0x9f
 db 0x23
 db 0xf4
 db 0x69
 db 0xb1
 db 0x38
 db 0x8d
 db 0x7b
 db 0x6d
 db 0x2e
 db 0xe4
 db 0x13
 db 0x83
 db 0x1c
 db 0xb0
 db 0x28
 db 0x84
 db 0xf
 db 0x6f
 db 0xfe
 db 0xfe
 db 0x69
 db 0xe9
 db 0x33
 db 0x9a
 db 0xcf
 db 0x70
 db 0x76
 db 0x77
 db 0x84
 db 0xdd
 db 0x16
 db 0xa7
 db 0xd1
 db 0x80
 db 0x58
 db 0xa
 db 0xd
 db 0xd3
 db 0x77
 db 0x3b
 db 0xb8
 db 0x8a
 db 0xbf
 db 0xd4
 db 0x3a
 db 0xe7
 db 0x58
 db 0x49
 db 0x56
 db 0x57
 db 0x47
 db 0xbf
 db 0x40
 db 0x7a
 db 0x5a
 db 0xf
 db 0xeb
 db 0xd0
 db 0x86
 db 0x6f
 db 0xad
 db 0x9d
 db 0x16
 db 0x7f
 db 0x1d
 db 0x6e
 db 0x89
 db 0x2a
 db 0x41
 db 0x0
 db 0x65
 db 0xf9
 db 0x8b
 db 0x24
 db 0xcd
 db 0xc5
 db 0xb
 db 0x26
 db 0xf
 db 0x61
 db 0x7d
 db 0x56
 db 0x21
 db 0xbd
 db 0xd1
 db 0x7b
 db 0xcc
 db 0xbc
 db 0x4b
 db 0x53
 db 0x2b
 db 0xf9
 db 0xf0
 db 0x41
 db 0x78
 db 0xd
 db 0xaf
 db 0x1
 db 0x37
 db 0xf0
 db 0x1
 db 0x9c
 db 0xea
 db 0x8c
 db 0xc1
 db 0xb7
 db 0x52
 db 0xcc
 db 0xdd
 db 0x61
 db 0x2e
 db 0x5a
 db 0xb7
 db 0x4f
 db 0x17
 db 0x88
 db 0xca
 db 0xe4
 db 0x44
 db 0x15
 db 0x37
 db 0x6f
 db 0xe
 db 0x27
 db 0xb0
 db 0x86
 db 0x34
 db 0x5f
 db 0x87
 db 0x6b
 db 0x50
 db 0x89
 db 0x7
 db 0x3a
 db 0x15
 db 0xc8
 db 0xf1
 db 0x67
 db 0x95
 db 0xcf
 db 0xc8
 db 0xc3
 db 0x29
 db 0x80
 db 0x12
 db 0x41
 db 0x8
 db 0xdc
 db 0x25
 db 0x4d
 db 0xf1
 db 0x5c
 db 0xbc
 db 0x0
 db 0x83
 db 0x6d
 db 0x86
 db 0xb7
 db 0xcc
 db 0xe
 db 0x22
 db 0x1c
 db 0x97
 db 0x29
 db 0x56
 db 0xac
 db 0xf2
 db 0x48
 db 0x14
 db 0x87
 db 0x17
 db 0xdc
 db 0x4a
 db 0x40
 db 0x5c
 db 0x5c
 db 0x81
 db 0x65
 db 0x38
 db 0xa6
 db 0xb2
 db 0x29
 db 0x2
 db 0x6e
 db 0x29
 db 0x85
 db 0xdb
 db 0xb0
 db 0x3c
 db 0xa8
 db 0xbe
 db 0x5e
 db 0xc4
 db 0x55
 db 0x88
 db 0x1b
 db 0x1
 db 0x7a
 db 0x63
 db 0x15
 db 0x1
 db 0x7a
 db 0xf2
 db 0x4b
 db 0xba
 db 0x4e
 db 0xa7
 db 0x3c
 db 0xb3
 db 0xdf
 db 0xe2
 db 0x65
 db 0x8
 db 0xe5
 db 0xd4
 db 0x32
 db 0x6a
 db 0xaf
 db 0xe2
 db 0xa7
 db 0x57
 db 0xa0
 db 0x5
 db 0x1c
 db 0xf5
 db 0x8d
 db 0x37
 db 0xf6
 db 0x7
 db 0x9a
 db 0xc
 db 0x8
 db 0x14
 db 0xfe
 db 0x53
 db 0xce
 db 0x4c
 db 0xfa
 db 0xa
 db 0x0
 db 0xd9
 db 0xed
 db 0x65
 db 0xe2
 db 0xd2
 db 0x39
 db 0x14
 db 0x3c
 db 0xe9
 db 0xf6
 db 0xe3
 db 0x40
 db 0x96
 db 0xe9
 db 0x5c
 db 0x8b
 db 0x76
 db 0x93
 db 0x81
 db 0x7e
 db 0x2d
 db 0x8d
 db 0x86
 db 0x41
 db 0x8b
 db 0xda
 db 0x10
 db 0xd8
 db 0xd4
 db 0x1a
 db 0xd8
 db 0xae
 db 0x7
 db 0x3d
 db 0x90
 db 0xd9
 db 0x77
 db 0xa4
 db 0x16
 db 0x60
 db 0x9a
 db 0xf9
 db 0xa0
 db 0x30
 db 0xe2
 db 0xfd
 db 0xbb
 db 0x59
 db 0x90
 db 0x3c
 db 0xd7
 db 0xbe
 db 0xca
 db 0x5d
 db 0xff
 db 0x55
 db 0x37
 db 0xf
 db 0x2d
 db 0xc
 db 0x2a
 db 0x5
myidt_base:
 ;My IDTs limit and base 0x20A and 0x20F in data page three
 db 0xa0
 db 0x0
 dd 0xd210
 ;My IDT Starts here at location 0x210 in data page three
idt_start:
;Interrupt vector for type 0
 db 0x10
 db 0x33
 db 0x0
 db 0xa
;Interrupt vector for type 1
 db 0x19
 db 0x33
 db 0x0
 db 0xa
;Interrupt vector for type 2
 db 0x22
 db 0x33
 db 0x0
 db 0xa
;Interrupt vector for type 3
 db 0x2b
 db 0x33
 db 0x0
 db 0xa
;Interrupt vector for type 4
 db 0x34
 db 0x33
 db 0x0
 db 0xa
;Interrupt vector for type 5
 db 0x3d
 db 0x33
 db 0x0
 db 0xa
;Interrupt vector for type 6
 db 0x46
 db 0x33
 db 0x0
 db 0xa
;Interrupt vector for type 7
 db 0x4f
 db 0x33
 db 0x0
 db 0xa
;Interrupt vector for type 8
 db 0x58
 db 0x33
 db 0x0
 db 0xa
;Interrupt vector for type 9
 dw 0x3385
 db 0x0
 db 0x0
 db 0xa
;Interrupt vector for type 10
 dw 0x3385
 db 0x0
 db 0x0
 db 0xa
;Interrupt vector for type 11
 dw 0x3385
 db 0x0
 db 0x0
 db 0xa
;Interrupt vector for type 12
 db 0x61
 db 0x33
 db 0x0
 db 0xa
;Interrupt vector for type 13
 db 0x6a
 db 0x33
 db 0x0
 db 0xa
;Interrupt vector for type 14
 dw 0x3385
 db 0x0
 db 0x0
 db 0xa
;Interrupt vector for type 15
 dw 0x3385
 db 0x0
 db 0x0
 db 0xa
;Interrupt vector for type 16
 db 0x73
 db 0x33
 db 0x0
 db 0xa
;Interrupt vector for type 17
 dw 0x3385
 db 0x0
 db 0x0
 db 0xa
;Interrupt vector for type 18
 db 0x7c
 db 0x33
 db 0x0
 db 0xa
 ;My IDT ends here for (0-18) descriptors
 ;Random data in remaining bytes of IDT
 db 0xba
 db 0x31
 db 0x43
 db 0x4a
 db 0xb
 db 0xba
 db 0xee
 db 0x21
 db 0x1a
 db 0x88
 db 0x1a
 db 0xba
 db 0xb8
 db 0xfd
 db 0xb7
 db 0x73
 db 0x56
 db 0x48
 db 0xaf
 db 0x2d
 db 0x6
 db 0x79
 db 0x8a
 db 0x5
 db 0xcf
 db 0xc2
 db 0x15
 db 0xfc
 db 0xce
 db 0x3f
 db 0x2
 db 0x88
 db 0x70
 db 0x45
 db 0xd2
 db 0x7b
 db 0xff
 db 0xc0
 db 0x9c
 db 0x19
 db 0x48
 db 0xb7
 db 0xd3
 db 0x0
 db 0xb4
 db 0x8b
 db 0x73
 db 0xa
 db 0xd3
 db 0x22
 db 0x37
 db 0xd9
 db 0x9c
 db 0xc1
 db 0xde
 db 0x6b
 db 0x83
 db 0xf3
 db 0x67
 db 0x51
 db 0x32
 db 0x69
 db 0xd9
 db 0xa3
 db 0xae
 db 0xab
 db 0x1e
 db 0xad
 db 0x6b
 db 0xbb
 db 0xc6
 db 0xb3
 db 0x72
 db 0x9a
 db 0xb3
 db 0x26
 db 0x25
 db 0x26
 db 0x30
 db 0xf8
 db 0x49
 db 0x67
 db 0xd1
 db 0xe5
 db 0x28
 db 0xaf
 db 0x50
 db 0xac
 db 0xa3
 db 0xb7
 db 0xfd
 db 0xd5
 db 0x21
 db 0xd7
 db 0x78
 db 0xcf
 db 0x82
 db 0x97
 db 0x7d
 db 0xee
 db 0x52
 db 0x43
 db 0xa1
 db 0xc4
 db 0xdd
 db 0x55
 db 0xea
 db 0x2
 db 0x7b
 db 0x1a
 db 0xfa
 db 0xc4
 db 0x81
 db 0xcb
 db 0xa9
 db 0xa9
 db 0x7b
 db 0xf9
 db 0x55
 db 0x1e
 db 0xb1
 db 0x53
 db 0xf3
 db 0xd2
 db 0x2a
 db 0x6c
 db 0xa1
 db 0xac
 db 0x3
 db 0x1e
 db 0x9a
 db 0x55
 db 0x62
 db 0x3c
 db 0x19
 db 0x3f
 db 0x91
 db 0x3
 db 0x42
 db 0xc
 db 0x1d
 db 0x3c
 db 0xd1
 db 0x9e
 db 0x8
 db 0x7a
 db 0x47
 db 0x83
 db 0x74
 db 0x9d
 db 0xa1
 db 0x25
 db 0xf0
 db 0x94
 db 0xf7
 db 0x1a
 db 0x0
 db 0x98
 db 0xc6
 db 0x3
 db 0xb7
 db 0x61
 db 0x58
 db 0x19
 db 0x9d
 db 0x71
 db 0x58
 db 0x2e
 db 0x74
 db 0x9a
 db 0x3a
 db 0x91
 db 0xd7
 db 0xb
 db 0x2f
 db 0xdf
 db 0x86
 db 0x77
 db 0x62
 db 0xfa
;Exception Handler routines

  excep_0: mov bx,0
           jmp excep_noerr
  excep_1: mov bx,1
           jmp excep_noerr
  excep_2: mov bx,2
           jmp excep_noerr
  excep_3: mov bx,3
           jmp excep_noerr
  excep_4: mov bx,4
           jmp excep_noerr
  excep_5: mov bx,5
           jmp excep_noerr
  excep_6: mov bx,6
           jmp excep_noerr
  excep_7: mov bx,7
           jmp excep_noerr
  excep_8: mov bx,8
           jmp excep_noerr
  excep_12: mov bx,12
           jmp excep_noerr
  excep_13: mov bx,13
           jmp excep_noerr
  excep_16: mov bx,16
           jmp excep_noerr
  excep_18: mov bx,18
           jmp excep_noerr
  excep_default:
  	 mov word [0x2208],0xface
  	 jmp chanSad
  excep_noerr:  
                 and esp,0xffff
                 mov ax,[ss:esp]
                 cmp word [0x2200],0xdead
                 jne near ind_excep
                 cmp bx,16
                 je fp_exception_point
                 mov [0x2200],ax
                 mov [0x2208],bx
                 jmp chanSad
 fp_exception_point: fnclex
                 inc word [0x2ff0]
                 jmp ind_ret2
  ind_excep:   add ax, word [0x2200]
               mov [ss:esp], ax
  	     mov word [0x2200],0xdead
 	     inc word [0x2ff8]
         	  ind_ret2:   iretw
 align 0x1000 


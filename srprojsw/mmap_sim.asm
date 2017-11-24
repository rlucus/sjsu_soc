	## Data Section:
	.data
	## ISR Temporary Storage Locations
	ISR00:	.word	0x00000000 # $ra
	ISR01:	.word	0x00000000 # $k1
	ISR02:	.word	0x00000000 # $a0
	ISR03:	.word	0x00000000 # $t0
	ISR04:	.word	0x00000000
	ISR05:	.word	0x00000000
	ISR06:	.word	0x00000000
	ISR07:	.word	0x00000000
	ISR08:	.word	0x00000000
	ISR09:	.word	0x00000000
	ISR10:	.word	0x00000000
	ISR11:	.word	0x00000000
	ISR12:	.word	0x00000000
	ISR13:	.word	0x00000000
	ISR14:	.word	0x00000000
	ISR15:	.word	0x00000000
	
	## Kernel Variable Locations
	EXCP_CODE:	.word	0x00000000
	TRAP_SET:	.word	0x00000000
	AES_DONE:	.word	0x00000000
	TEST_WORD:	.word	0x00000000
	OTHER_INTR:	.word	0x00000000

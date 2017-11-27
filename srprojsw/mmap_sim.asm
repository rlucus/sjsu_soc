	## Data Section:
	.data
	## ISR Temporary Storage Locations
	ISRS0:	.word	0x00000000 # $ra
	ISRS1:	.word	0x00000000 # $k1
	ISRS2:	.word	0x00000000 # $a0
	ISRS3:	.word	0x00000000 # $t0

	ISRI0:	.word	0x00000000

	## Kernel Variable Locations
	EXCP_CODE:	.word	0x00000000
	TRAP_SET:	.word	0x00000000
	AES_DONE:	.word	0x00000000
	TEST_WORD:	.word	0x00000000
	OTHER_INTR:	.word	0x00000000

	## Simulated Devices:
	UART:	.word	0x00000000

	## Data Section:

	## ISR Temporary Storage Locations - Shared
	# These locations are shared with the scheduler so that
	# it may retain the contents in a task's PCB.
	.eqv	ISRS0	0x7EE0 # CP0/R14 - Interrupted Instruction
	.eqv	ISRS1	0x7EE4 # $ra - Return address of interrupted proc
	.eqv	ISRS2	0x7EE8 # $k1 - Kernel register
	.eqv	ISRS3	0x7EEC # $t0 - Temporary register 0

	## ISR Temporary Storage Locations - Internal
	# These locations are internal to the ISR and are
	# off limits for other processes.
	.eqv	ISRI0	0x7EC0 # Interrupt statuses
	
	## Kernel Variable Locations
	# Common kernel operating variables
	.eqv	EXCP_CODE	0x7020
	.eqv	TRAP_SET	0x7024
	.eqv	AES_DONE	0x7028
	.eqv	OTHER_INTR	0x702C
	.eqv	TEST_WORD	0x7030

	## Device Addresses:
	.eqv	UART	0x7000

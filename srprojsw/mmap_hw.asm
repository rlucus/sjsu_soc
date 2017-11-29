	## Data Section:

	## ISR Temporary Storage Locations - Shared
	# These locations are shared with the scheduler so that
	# it may retain the contents in a task's PCB.
	.eqv	ISRS0	0x7EE0 # CP0/R14 - Interrupted Instruction
	.eqv	ISRS1	0x7EE4 # $ra - Return address of interrupted proc
	.eqv	ISRS2	0x7EE8 # $k1 - Kernel register
	.eqv	ISRS3	0x7EEC # $t0 - Temporary register 0

	##Scheduler Storage Locations
	.eqv	PCB_BASE0	0x6000
	.eqv	PCB_BASE1	0x6100
	.eqv	PCB_BASE2	0x6200
	.eqv	PCB_BASE3	0x6300
	.eqv	PCB_BASE4	0x6400
	.eqv	PCB_BASE5	0x6500
	.eqv	PCB_BASE6	0x6600
	.eqv	SCHED_STATUS	0x7FE0
	.eqv	SCHED_LAST_TASK 0x7FE4
	.eqv	iMEM_BASE_MASK	0x1000
	.eqv	dMEM_END_MASK	0x00FF
	.eqv	dMEM_OFFSET_MASK	0x0008

	.eqv	SCHEDS0	0x7FF0 # CP0/R14 - Interrupted Instruction
	.eqv	SCHEDS1	0x7FF4 # $ra - Return address of interrupted proc
	.eqv	SCHEDS2	0x7FF8 # $k1 - Kernel register
	.eqv	SCHEDS3	0x7FFC # $t0 - Temporary register 0

	.eqv	PCB_PC_OFFSET	0
	.eqv	PCB_AT_OFFSET	4
	.eqv	PCB_V0_OFFSET	8
	.eqv	PCB_V1_OFFSET	12
	.eqv	PCB_A0_OFFSET	16
	.eqv	PCB_A1_OFFSET	20
	.eqv	PCB_A2_OFFSET	24
	.eqv	PCB_A3_OFFSET	28
	.eqv	PCB_T0_OFFSET	32
	.eqv	PCB_T1_OFFSET	36
	.eqv	PCB_T2_OFFSET	40
	.eqv	PCB_T3_OFFSET	44
	.eqv	PCB_T4_OFFSET	48
	.eqv	PCB_T5_OFFSET	52
	.eqv	PCB_T6_OFFSET	56
	.eqv	PCB_T7_OFFSET	60
	.eqv	PCB_S0_OFFSET	64
	.eqv	PCB_S1_OFFSET	68
	.eqv	PCB_S2_OFFSET	72
	.eqv	PCB_S3_OFFSET	76
	.eqv	PCB_S4_OFFSET	80
	.eqv	PCB_S5_OFFSET	84
	.eqv	PCB_S6_OFFSET	88
	.eqv	PCB_S7_OFFSET	92
	.eqv	PCB_T8_OFFSET	96
	.eqv	PCB_T9_OFFSET	100
	.eqv	PCB_K0_OFFSET	104
	.eqv	PCB_K1_OFFSET	108
	.eqv	PCB_GP_OFFSET	112
	.eqv	PCB_SP_OFFSET	116
	.eqv	PCB_FP_OFFSET	120
	.eqv	PCB_RA_OFFSET	124

	## ISR Temporary Storage Locations - Internal
	# These locations are internal to the ISR and are
	# off limits for other processes.
	.eqv	ISRI0	0x7EC0 # Interrupt statuses
	.eqv	ISRI1	0x7EC4 # Interrupt controls
	.eqv	ISRI2	0x7EC8 # RA for PROC_INTR_PROCESS
	
	## Kernel Variable Locations
	# Common kernel operating variables
	.eqv	EXCP_CODE	0x7020
	.eqv	TRAP_SET	0x7024
	.eqv	AES_DONE	0x7028
	.eqv	OTHER_INTR	0x702C
	.eqv	TEST_WORD	0x7030

	## Device Addresses:
	.eqv	UART	0x7000
	
	.eqv sentence 0x0 # Keep the message in the phrase

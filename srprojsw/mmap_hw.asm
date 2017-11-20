	## Data Section:

	## ISR Temporary Storage Locations
	.eqv	ISR00	0x7ee0 # $ra
	.eqv	ISR01	0x7ee1 # $k1
	.eqv	ISR02	0x7ee2 # $a0
	.eqv	ISR03	0x7ee3 # $t0
	.eqv	ISR04	0x7ee4
	.eqv	ISR05	0x7ee5
	.eqv	ISR06	0x7ee6
	.eqv	ISR07	0x7ee7
	.eqv	ISR08	0x7ee8
	.eqv	ISR09	0x7ee9
	.eqv	ISR10	0x7eeA
	.eqv	ISR11	0x7eeB
	.eqv	ISR12	0x7eeC
	.eqv	ISR13	0x7eeD
	.eqv	ISR14	0x7eee
	.eqv	UART	0x7eeF
	
	## Kernel Variable Locations
	.eqv	EXCP_CODE	0x7020
	.eqv	TRAP_SET	0x7021
	.eqv	AES_DONE	0x7022
	.eqv	TEST_WORD	0x7023

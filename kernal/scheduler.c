

void schedInit(void) {

	//array of base addresses for the PCB of each task
	const int* entry[7] = {	0x00007F00,0x00007F20,0x00007F40,0x00007F60,
							0x00007F80,0x00007FA0,0x00007FC0,0x00007FE0};
	const int gp=28, sp=29, fp=30, ra=31;

	*entry[0]=0; //location of status register
	//	[xxxxxxxxxx	|	6543210	|	6543210	]
	//	[unused		| currTask 	| validTask	]

	for (int i = 0; i < 7; i++) {
		//set initial values for pointer registers
		*entry[i + sp] = (i << 12) | 0x0FFF; 	//12 to move to the upper nibble
		*entry[i + fp] = (i << 12) | 0x0FFF;
		*entry[i + gp] = (i << 12);				//base addr
		*entry[i + ra] = (i << 12);	
	}
	//setup for first run
	//this needs to be modified once I have memory map of iMem
	//should be set to first instruction of the task6
	__asm("addi $t0, $0, 0x7FE0") 
	__asm("mtc0 $t0, $14");

	//this needs to be modified if the number of tasks
	*entry[0] |= (3 << 0); //mark first 2 tasks valid;
	*entry[0] |= (1 << 13); //mark last task as running, so that task0 will start first
	
	//start sched
	sched();

	error(); //jump to error if reached

}

void sched(void) {
	const int* status = 0x00007F00;
//get currently running task

//save registers to 

//get next valid task

}



ISR{


	handler = determineInterruptSource();

	move($ra into memAddr1)

	jal(Handler)

	move(restore $ra from memAddr1)

	finishISR()

	move(CP0$14 into $k0)

	jr($k0)
}

timerHandler { 
	move($ra into memAddr2)

	jal(scheduler)

	move(restore $ra from memAddr2)

	jr($ra)

}


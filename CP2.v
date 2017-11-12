`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This is the wrapper module for the AES_block encryption.
// This is designed as a black box to be dropped in as 
// Co-Processor Two in the Main module.
// The modified AES has block (128-bit) input/output data. 
// -This wrapper will accept word writes (MFcp2/MTcp2) for the following
// 		-read:  status / set DMA start address
// 		-write: key writes/ DMA starting address / data length (bytes) / encode decode / start bit 
// -upon go, internal DMA will hold/read/write data from external memory to local process registers
// -Data will encrypted/decrypted one block at a time until complete
//      -DMA request HOLD
// 		-DMA will return processed data to originl location in external memory. 
// 		-INT will be triggered
//////////////////////////////////////////////////////////////////////////////////
// NOTE: This module requires block (4-word/128-bits) aligned allocation in external memory. 
// ie: if a single word is encrypted, it will still return a block of memory write back
// overwriting anything squentialy from the starting memory addresses
//		-any data not block aligned will be automatically padded with zeroes (0)
//////////////////////////////////////////////////////////////////////////////////

module CP2(
	input              clk, rst,
	input              we_cpu,
	input  wire [ 5:0] addr_cpu,
	input  wire [31:0] wrData_cpu,
	output wire [31:0] rdData_cpu,

	output reg        we_dma, 
	output reg [31:0] addr_dma, 
	input  wire[31:0] wrData_dma,
	output reg [31:0] rdData_dma,

	input         HOLD_ACK,
	output   	  INT, HOLD
	);

	///////////// STATE MACHINE PARAMETERS ////////////
	parameter [5:0] idle        = 0;
	parameter [5:0] dmaSet	    = 1;
	parameter [5:0] dmaAck      = 2;
	parameter [5:0] dmaReadA    = 3;
	parameter [5:0] dmaReadB    = 4;
	parameter [5:0] dmaReadC    = 5;
	parameter [5:0] dmaReadD    = 6;
	parameter [5:0] dmaPadB     = 7;
	parameter [5:0] dmaPadC     = 8;
	parameter [5:0] dmaPadD     = 9;
	parameter [5:0] dmaReadDone = 10;
	parameter [5:0] dmaWaitA    = 11;
	parameter [5:0] dmaWaitB    = 12;
	parameter [5:0] dmaWriteA   = 13;
	parameter [5:0] dmaWriteB   = 14;
	parameter [5:0] dmaWriteC   = 15;
	parameter [5:0] dmaWriteD   = 16;
	parameter [5:0] dmaWriteE   = 17;
	parameter [5:0] dmaWriteDone= 18;

	parameter [5:0] loadKeyA    = 19;
	parameter [5:0] loadKeyB    = 20;
	parameter [5:0] loadKeyC    = 21;
	parameter [5:0] loadKeyD    = 22;
	parameter [5:0] loadKeyE    = 23;
	parameter [5:0] loadKeyWait = 24;
	parameter [5:0] aesRdy      = 25;
	parameter [5:0] loadDatA    = 26;
	parameter [5:0] loadDatAA   = 27;
	parameter [5:0] loadDatB    = 28;
	parameter [5:0] loadDatC    = 29;
	parameter [5:0] loadDatD    = 30;
	parameter [5:0] loadDatWait = 31;
	parameter [5:0] readDatA    = 32;
	parameter [5:0] readDatB    = 33;
	parameter [5:0] aesDone     = 34;
	
	localparam ADDR_CTRL        = 8'h08;
	localparam ADDR_CONFIG      = 8'h0a;
    localparam ADDR_KEY0        = 8'h10;
    localparam ADDR_KEY1        = 8'h17;
    localparam ADDR_BLOCK0      = 8'h20;
    localparam ADDR_RESULT0     = 8'h30;

	///////////// END STATE MACHINE PARAMETERS ////////////

    reg cs_aes, we_aes;
    reg [127:0] wd_aes;
	reg [7:0] addr_aes;
	wire [127:0] rd_aes;

	aes_block b1(
       .clk(clk),
       .reset_n(~rst),
       
       .cs(cs_aes),
       .we(we_aes),
       .address(addr_aes),
       .write_block(wd_aes),
       .read_block(rd_aes)
	   );

	reg [5:0] length = 0;
	reg [5:0] i = 0;
	reg [5:0] state_dma = idle;
    reg [5:0] state_aes = idle;
    reg [7:0] keyWait, dataWait;
    
	// CPU interface/status reg    // 31 , 30,      29,     28,   27-25, 24(RO), ..., 15:0
	// [0] status		           // INT, go, 128/256, encDec, clkMult, hold  ,  0 , words of data
	// [1] start address
	// [2] KEY_0
	// [3] KEY_1
	// [4] KEY_2
	// [5] KEY_3
	// [6] KEY_4
	// [7] KEY_5
	// [8] KEY_6
	// [9] KEY_7
	reg [31:0] reg_cpu [9:0];

	// internal registers; 64kB; each set forms a block
	reg [31:0] r00 [0:3999];
	reg [31:0] r01 [0:3999];
	reg [31:0] r10 [0:3999];
	reg [31:0] r11 [0:3999];

	// no CPU output if AES is running : Write Only for Key
//	assign rdData_cpu = (!go && (addr_cpu<2)) ? reg_cpu[addr_cpu] : 0 ; 
	assign INT        = reg_cpu[0][31];						// INT bit
	assign HOLD       = reg_cpu[0][24]; 
	assign rdData_cpu = (addr_cpu<2 ) ? reg_cpu[addr_cpu] : 0;
    assign keyLen     = reg_cpu[0][29];
    assign encode     = reg_cpu[0][28];
	
	always @ (posedge clk, posedge rst) begin
		if(rst) begin

			for(i=0; i<10; i=i+1)begin
				reg_cpu[i] = 0;
			end
/*			for(i=0; i<4000; i=i+1)begin
				r00[i] = 0;
				r01[i] = 0;
				r10[i] = 0;
				r11[i] = 0;
			end*/
		end // END rst
		else begin
			if(we_cpu)  reg_cpu[addr_cpu] = (addr_cpu==0)? {wrData_cpu[31:25], reg_cpu[0][24], wrData_cpu[23:0] } : wrData_cpu;
		end
	end


    always @ (posedge clk) begin
        case(state_dma)
            idle	  : state_dma = reg_cpu[0][30] ? dmaSet : idle; // WHILE go !=1  
            dmaSet    : begin
                        reg_cpu[0][24]<= 1;
                        //self.clk = clk*1;				// reset clk
                        addr_dma  <= reg_cpu[1][31:0]; 
                        we_dma     = 0;
                        i          = 0;
                        length     = 0;
                        reg_cpu[0][30] = 0;
                        state_dma <= dmaAck;              											 end
            dmaAck    : state_dma  = HOLD_ACK ? dmaReadA : dmaAck;
            dmaReadA  : begin 
                        r00[i]    <= wrData_dma;
                        addr_dma   = addr_dma + 4;
                        length     = length + 1;
                        state_dma  = (length < reg_cpu[0][15:0])? dmaReadB : dmaPadB;                end
            dmaReadB  : begin
                        r01[i]    <= wrData_dma;
                        addr_dma   = addr_dma + 4;
                        length     = length + 1;
                        state_dma  = (length < reg_cpu[0][15:0])? dmaReadC : dmaPadC;                end
            dmaReadC  : begin
                        r10[i]    <= wrData_dma;
                        addr_dma   = addr_dma + 4;
                        length     = length + 1;
                        state_dma  = (length < reg_cpu[0][15:0])? dmaReadD : dmaPadD;                end
            dmaReadD  : begin
                        r11[i]    <= wrData_dma;
                        addr_dma   = addr_dma + 4;
                        length     = length + 1;
                        i          = i + 1;
                        state_dma  = (length < reg_cpu[0][15:0])? dmaReadA : dmaReadDone;            end
            dmaPadB   : begin
                        r01[i]     = 0;
                        length     = length + 1;
                        state_dma  = dmaPadC;                     end
            dmaPadC   : begin
                        r10[i]     = 0;
                        length     = length + 1;
                        state_dma  = dmaPadD;                     end
            dmaPadD   : begin
                        r11[i]     = 0;
                        length     = length + 1;
                        i          = i + i;
                        state_dma  = dmaReadDone;  			      end    
            dmaReadDone: begin
                        reg_cpu[0][24]= 0;
                         // self.clk = clk*reg_cpu[27:25]   // Boost clk
                         // state_aes idle -> loadKey | process
                        state_dma = dmaWaitA;                     end
            dmaWaitA  : state_dma = (reg_cpu[0][24]) ? dmaWaitB  : dmaWaitA; // wait for AES to complete 
            dmaWaitB  : state_dma = (HOLD_ACK)   ? dmaWriteA : dmaWaitB;
    
            dmaWriteA : begin
                        we_dma    <= 1;
                        addr_dma  <= reg_cpu[1][31:0]; 
                        state_dma  = dmaWriteB;	                  end         
            dmaWriteB : begin
                        rdData_dma = r00[i];
                        length     = length - 4;
                        state_dma  = dmaWriteC;                   end
            dmaWriteC : begin
                        rdData_dma = r01[i];
                        addr_dma   = addr_dma + 4;
                        state_dma  = dmaWriteD;                   end
            dmaWriteD : begin
                        rdData_dma = r10[i];
                        addr_dma   = addr_dma + 4;
                        state_dma  = dmaWriteE;                   end
            dmaWriteE : begin
                        rdData_dma = r11[i];
                        addr_dma   = addr_dma + 4;
                        i          = i + i;
                        state_dma  = (length > 0) ? dmaWriteB : dmaWriteDone;        end
            dmaWriteDone:begin 
                        we_dma     = 0;
                        reg_cpu[0][24] = 0;
                        reg_cpu[0][31] = 1;
                        state_dma  = idle; 	                      end	    
            default    : state_dma = idle;        		            
        endcase // ENDCASE STATE_DMA
    end 
    
    always @ (posedge clk) begin
        case(state_aes)
            idle	  : state_aes = reg_cpu[0][30] ? loadKeyA : idle;
            loadKeyA  :begin
                        cs_aes     = 1;
                        we_aes     = 1;
                        addr_aes   = ADDR_KEY0;
                        wd_aes    <= {reg_cpu[9], reg_cpu[8], reg_cpu[7], reg_cpu[6]};
                        state_aes  = loadKeyB;  end
            loadKeyB  :begin
                        addr_aes  <= ADDR_KEY1;
                        wd_aes    <= {reg_cpu[5], reg_cpu[4], reg_cpu[3], reg_cpu[2]};
                        state_aes  = loadKeyC;  end
            loadKeyC  :begin
                        addr_aes  <= ADDR_CONFIG; 
                        wd_aes    <= {254'h0, keyLen, 1'b0};
                        state_aes  = loadKeyD;  end
            loadKeyD  :begin
                        addr_aes  <= ADDR_CTRL;
                        wd_aes    <= 1;
                        keyWait    = 0;
                        state_aes  = loadKeyE;  end
            loadKeyE  :begin
                        cs_aes     = 0;
                        we_aes     = 0;
                        state_aes  = loadKeyWait;  end
            loadKeyWait:begin
                        keyWait   = keyWait + 1;			// spin to allow key to set
                        state_aes = (keyWait>14) ? aesRdy : loadKeyWait;   end

            aesRdy    : state_aes = reg_cpu[0][24] ? aesRdy : loadDatA;
            
            loadDatA  :begin
    					i         <= i - 1;
            			state_aes  = loadDatAA;   end
            loadDatAA :begin
                       cs_aes     <= 1;
                       we_aes     <= 1;
                       addr_aes   <= ADDR_BLOCK0;
                       wd_aes     <= {r11[i], r10[i], r01[i], r00[i]};
                       state_aes   = loadDatB;    end
            loadDatB  :begin
                       addr_aes   <= ADDR_CONFIG;
                       wd_aes     <= {254'h0, keyLen, encode};
                       state_aes   = loadDatC;    end
            loadDatC  :begin
                       addr_aes   <= ADDR_CTRL;
                       wd_aes     <= 2;
                       state_aes   = loadDatD;    end
            loadDatD  :begin
                       cs_aes      = 0;
                       we_aes      = 0;		  		    
                       dataWait    = 0;
                       state_aes   = loadDatWait;  end
            loadDatWait:begin
                       dataWait   = dataWait + 1;			// spin to allow data to process
                       state_aes = (dataWait>74) ? readDatA : loadDatWait;    end
    
            readDatA  :begin
                       we_aes      = 0;
                       cs_aes      = 1;
                       addr_aes   <= ADDR_RESULT0;
                       state_aes   = readDatB;                      end
            readDatB  :begin
                       {r11[i], r10[i], r01[i], r00[i]} <= rd_aes;
                       state_aes   = (i>0) ? loadDatA : aesDone;    end
            aesDone   :begin
                       cs_aes      = 0;
                       reg_cpu[0][24]  = 1;						// triggers DMA to continue
                       state_aes   = idle;                          end 
            default   : state_aes = idle;
        endcase // ENDCASE AES_STATE 
    end

endmodule






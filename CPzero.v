module CPzero 
(input clk, rst, we1, alu_trap, [4:0] addr, [5:0] interrupt, [31:0] wd, pcp4,  
 output exl, iv, [31:0] rd1);
    
    // if need full space then use the following line.
    // reg [32:0] rf [0:31];
    reg [31:0] rf [0:15];
    
    assign rd1 = (addr) ? rf[addr] : 0; // assign output to data or zero
    
    // external flag assigns
    assign iv  = rf[13][23];            // handler location, which location to select (180|200)
    assign exl = rf[12][1];             // external flag to CU for any interrupt
    always @ (posedge exl) begin        // capture pc+4 Return addr when INT flag is set
        rf[14] = pcp4;
    end
    
    always @ (posedge rst) begin
        // MIPS ISA leaves most of the values within this module as 
        // undefined on startup. To allow functional verification in the 
        //testbench, used register files 12-14 are initilized to zero
        rf[12] <= 0;
        rf[13] <= 0;
        rf[14] <= 0;
    end

    always @ (posedge alu_trap) begin   // trigger trap from ALU
        rf[13][8] = 1'b1;
    end


    // negedge clock
    always @ (negedge clk)
    begin      
        if(rf[13][15:10] > 0) begin      // Interrupt Vectors
            rf[13][6:2] <= 5'b00000; 
        end 
        else if(rf[13][9:8] > 0) begin   // traps
            rf[13][6:2] <= 5'b01101;
        end 
        else begin                       // default no value processed
            rf[13][6:2] <= 5'b01010;
        end
    end
    

    always @ (interrupt, rf[13][9:8]) begin
        // set INT flags
        if (rf[12][0] == 1) begin             
            rf[13][10] <= (interrupt[0] & rf[12][10]);
            rf[13][11] <= (interrupt[1] & rf[12][11]);
            rf[13][12] <= (interrupt[2] & rf[12][12]);
            rf[13][13] <= (interrupt[3] & rf[12][13]);
            rf[13][14] <= (interrupt[4] & rf[12][14]);
            rf[13][15] <= (interrupt[5] & rf[12][15]);
        end   
        rf[12][1] = rf[13][15:8] ? 1'b1 : 0;    // Set EXL flag to CU
    end


    always @ (posedge clk) begin   
        // clear int flags
        if((rf[12][ 8]) == 0) rf[13][ 8] <= 1'b0;
        if((rf[12][ 9]) == 0) rf[13][ 9] <= 1'b0;
        if((rf[12][10]) == 0) rf[13][10] <= 1'b0;
        if((rf[12][11]) == 0) rf[13][11] <= 1'b0;
        if((rf[12][12]) == 0) rf[13][12] <= 1'b0;
        if((rf[12][13]) == 0) rf[13][13] <= 1'b0;
        if((rf[12][14]) == 0) rf[13][14] <= 1'b0;
        if((rf[12][15]) == 0) rf[13][15] <= 1'b0;
        rf[12][1] = rf[13][15:8] ? 1'b1 : 0;    // Set EXL flag to CU

        // Write/Read to reg
        case(addr)  
            5'b01100:                          //reg 12
                if(we1) begin
                    rf[addr][31:16]<= 0;
                    rf[addr][15:8] <= wd[15:8];
                    rf[addr][7:1]  <= 0;
                    rf[addr][0]    <= wd[0];
                end
            5'b01101:                          //reg 13
                if(we1) begin
                    rf[addr][31:24] <= 0;
                    rf[addr][23]    <= wd[23];
                    rf[addr][22:16] <= 0;
                    rf[addr][7]     <= 0;
                    rf[addr][1:0]   <= 0;
                   
                    //traps
                    if(rf[12][9] == 1) begin //trap1
                        rf[addr][9] <= wd[9];
                    end
                    if(rf[12][8] == 1) begin //trap0
                        rf[addr][8] <= wd[8];
                    end       
                end
            5'b01110:                          //reg 14
                if(we1) begin
                    rf[addr] <= wd;
                end
        endcase // END case(addr)
    end

endmodule
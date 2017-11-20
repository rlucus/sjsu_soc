`timescale 1ns / 1ps
module mipscore_tb();

    reg clk, rst= 0;
    wire [31:0] pc_current, instr, alu_out, wd_dm, rd_dm;
    integer INT;

    mips_top u1 (.clk(clk), .rst(rst), 
        .pc_current(pc_current), .instr(instr), 
        .dmem_addr(alu_out), .dmem_out(wd_dm), .rd_dm(rd_dm), .INT(INT[3:0]), .serialClk(clk));
    initial begin
        INT = 4'h0;
        rst = 0;
        bounce();
        rst = 1;
        bounce();
        rst = 0;
        
        //while(pc_current != 32'h0000005C)
        //repeat (150)
        //repeat (600)
        repeat (100000)    
            begin
            bounce();
            end
        //$stop;
        
        INT = 4'b1111;
        #5;
        //bounce();
        #5;
        INT = 0;
        
        repeat (10)
        begin
            bounce();
        end
        
        $display ("Test Done");
        $stop;
    
    end
    
    
    
    
    //move clock forward
    task bounce;
        begin
            clk = 1;
            #5;
            clk = 0;
            #5;
        end
    endtask
    
    
endmodule

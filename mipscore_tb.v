`timescale 1ns / 1ps
module mipscore_tb();

    reg clk, rst= 0;
    wire [31:0] pc_current, instr, alu_out, wd_dm, rd_dm;
    integer INT;

    mips_top u1 (.clk(clk), .rst(rst), 
        .pc_current(pc_current), .instr(instr), 
        .alu_out(alu_out), .wd_dm(wd_dm), .rd_dm(rd_dm), .INT(INT[4:0]));
    initial begin
        INT = 5'b00000;
        rst = 0;
        bounce();
        rst = 1;
        bounce();
        rst = 0;
        
        //while(pc_current != 32'h0000005C)
        //repeat (150)
        repeat (600)    
            begin
            bounce();
            end
        //$stop;
        
        INT = 5'b11111;
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

`timescale 1ns / 1ps
module mipscore_tb();

    reg clk, rst= 0;
    wire [31:0] pc_current, instr, alu_out, wd_dm, rd_dm;

    mips_top u1 (.clk(clk), .rst(rst), 
        .pc_current(pc_current), .instr(instr), 
        .alu_out(alu_out), .wd_dm(wd_dm), .rd_dm(rd_dm));
    initial begin
        rst = 0;
        bounce();
        rst = 1;
        bounce();
        rst = 0;
        
        repeat (50)
            begin
            bounce();
       
            if(pc_current==32'h0000005C)
            begin
                $display ("Test Done");
                $stop;
            end
            end
        //$stop;
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

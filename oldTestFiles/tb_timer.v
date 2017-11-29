`timescale 1ns / 1ps

module tb_timer();

    reg clk, reset, we;
    wire flag;
    reg [4:0] addr;
    reg [31:0] dataIn;
    
    timer #(200) dut1 (.clk(clk), .rst(reset), .we(we), .addr(addr), .dataIn(dataIn), .flag(flag));

    initial begin
        addr = 0;
        we = 0;
        dataIn = 0;
        clk = 0;
        reset = 0;
        bounce;
        reset = 1;
        bounce();
        reset = 0;
        
        repeat (201)
        begin
            bounce;
        end
        
        addr = 5'b10110;
        dataIn = 0;
        we = 1;
        bounce;
        
        addr = 5'b10111;
        dataIn = 500;
        bounce;
        
        we = 0;
        addr = 0;
        
        repeat(201)
        begin
            bounce;
        end
            
    end



    task bounce;
        begin
            clk = 1;
            #5;
            clk = 0;
            #5;
        end
    endtask



endmodule
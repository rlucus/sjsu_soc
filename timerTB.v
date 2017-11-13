`timescale 1ns / 1ps
module timerTB;
    reg inclk;
    reg slow;
    wire sigout;
    timer timey(.fastclk(inclk), .slowclk(slow), .out(sigout));
    
    initial begin
        inclk = 0;
        forever
            #50 inclk = !inclk;
    end
    
    initial begin
        slow = 0;
        forever 
            #2500 slow = !slow;
    end
endmodule
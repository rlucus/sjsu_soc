`timescale 1ns/10ps

module uart_top_tb();

reg clk, reset, we;
reg [31:0] address, dataIn;
wire serial; 

uart_top DUT1(.RClk(clk), .clk(clk), .reset(reset), .we(we), .dataIn(dataIn), .address(address), .serial(serial));

initial begin

    reset = 0;
    clk = 0;
    we = 0;
    bounce();
    reset = 1;
    bounce();
    reset = 0;
    bounce();
    address = 32'h0000_0000;
    dataIn = 32'hAA_AA_AA_AA;
    bounce();
    reset = 0;
    bounce();
    reset = 0;
    bounce();

    we = 1;
    address = 32'hFFFF_FFFF;
    bounce();
    we = 0;
    address = 32'h0000_0000;
    
    //write another word
    we = 0;
    address = 32'h0000_0000;
    dataIn = 32'h87_65_43_21;
    bounce();
    reset = 0;
    bounce();

    we = 1;
    address = 32'hFFFF_FFFF;
    bounce();
    we = 0;
    address = 32'h0000_0000;
    
    
    
    repeat(100000)
    begin
        bounce();
    end
    
    //write another word
    we = 0;
    address = 32'h0000_0000;
    dataIn = 32'h1E_2D_3C_4B;
    bounce();
    reset = 0;
    bounce();

    we = 1;
    address = 32'hFFFF_FFFF;
    bounce();
    we = 0;
    address = 32'h0000_0000;

    repeat(10000000)
    begin
        bounce();
    end    


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
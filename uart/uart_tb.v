`timescale 1ns/10ps

module uart_tb();

reg clk, we, reset;
reg [31:0] address, dataIn;
wire serial, o_Tx_Active, o_Tx_Done;
wire busy;
wire [31:0] dataOut;

uart DUT1 (.clk(clk), .reset_n(reset), 
    .tx_ena(we), .tx_data(dataIn), 
    .rx(), .rx_busy(), 
    .rx_error(), .rx_data(dataOut), 
    .tx_busy(busy), .tx(serial));





initial begin
    clk = 0;
    we = 0;
    reset = 1;
    dataIn = 32'h12_34_56_78;
    
    bounce();
    reset = 0;
    bounce();
    reset = 1;
    we = 1;
    bounce();
    we = 0;
    
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

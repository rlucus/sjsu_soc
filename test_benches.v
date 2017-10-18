`resetall
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2017 12:58:16 PM
// Design Name: 
// Module Name: fifo_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fifo_tb();
    reg [7:0] in_data;
    reg trigger_read, trigger_write, reset;
    wire [7:0] out_data;
    wire is_full, is_empty;
    integer i;
    fifo #(.WSIZE(8),.FIFOLEN(8)) fifo_dut(.write_data(in_data), .read_data(out_data),
        .trigger_read(trigger_read), .trigger_write(trigger_write),
        .reset(reset), .fifo_full(is_full), .fifo_empty(is_empty)
    );
    
    initial begin
        #1 reset = 1'b1;
        #1 reset = 1'b0;
        in_data = 32'd202;
        for (i = 0; i < 10; i = i + 1) begin
            in_data = i;
            #1 trigger_write = 1'b1;
            #1 trigger_write = 1'b0;
        end
        
        for (i = 10; i < 15; i = i + 1) begin
            #1 trigger_read = 1'b1;
            #1 trigger_read = 1'b0;
        end
        
        for (i = 15; i < 19; i = i + 1) begin
            in_data = i;
            #1 trigger_write = 1'b1;
            #1 trigger_write = 1'b0;
        end
        #1;
        $stop();
    end
endmodule
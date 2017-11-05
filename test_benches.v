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

module block_to_word_disassembler_tb();
    reg [127:0] block_in;
    wire [31:0] word_out;
    
    reg block_in_ready, word_out_hold;
    wire word_ready, pull_block;
    
    reg clock, reset;
    
    block_to_word_disassembler btw_dis_DUT(.block_in(block_in), .word_out(word_out),
        .block_in_ready(block_in_ready), .word_out_hold(word_out_hold),
        .word_ready(word_ready), .pull_block(pull_block),
        .clock(clock), .reset(reset));
    
    
    parameter BLOCK_1 = 128'h0123_0ABC__0456_0DEF__0789_1ABC__1123_1DEF;
    parameter BLOCK_2 = 128'h0ABC_0123__0DEF_0456__1ABC_0789__1DEF_1123;
    parameter BLOCK_3 = 128'h1111_2222__3333_4444__5555_6666__1212_3434;
    
    initial begin
        hit_reset;
        
        block_in = BLOCK_1;
        block_in_ready = 1'b1;
        
        tick; tick; tick; tick;
         block_in = BLOCK_2;
         tick;
        
        tick; tick; tick;
         word_out_hold = 1'b1;
         tick;
         word_out_hold = 1'b0;
         tick; tick;
        
        tick; tick; tick; tick; tick;
    end
    
    task tick;
        begin
            #1 clock = 1'b1;
            #1 clock = 1'b0;
        end
    endtask
    
    task hit_reset;
        begin
            block_in = 128'b0;
            word_out_hold = 1'b0;
            block_in_ready = 1'b0;
            clock = 1'b0;
            reset = 1'b0;
            
            #1 reset = 1'b1;
            #1 reset = 1'b0;
        end
    endtask
endmodule


module word_to_block_assembler_tb();
    reg [31:0] word_in;
    wire [127:0] block_out;
    reg word_in_ready, block_out_hold;
    wire block_ready, pull_word;
    
    reg clock, reset;
    
    word_to_block_assembler #(.WSIZE(32)) wtb_assembler_dut (
        .word_in(word_in),
        .word_in_ready(word_in_ready),
        .block_out_hold(block_out_hold),
        .block_out(block_out),
        .block_ready(block_ready),
        .pull_word(pull_word),
        .clock(clock),
        .reset(reset)
    );
    initial begin
        hit_reset;
        
        word_in = 32'h0000_C0D1;
        word_in_ready = 1'b1;
        tick;
        
        word_in = 32'h0000_D0C1;
        tick;
        
        word_in = 32'h0000_E0F1;
        tick;
        
        word_in = 32'h0000_F0E1;
        tick;
        block_out_hold = 1'b1;
        tick;tick;tick;tick;tick; // just some random clocks to check and see what happens
        block_out_hold = 1'b0;
        tick;tick;tick;
        $stop();
    end
    
    task tick;
        begin
            #1 clock = 1'b1;
            #1 clock = 1'b0;
        end
    endtask
    
    task hit_reset;
        begin
            block_out_hold = 1'b0;
            word_in_ready = 1'b0;
            clock = 1'b0;
            word_in = 32'b0;
            
            #1 reset = 1'b1;
            #1 reset = 1'b0;
        end
    endtask
endmodule
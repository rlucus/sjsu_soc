`timescale 1ns / 1ps


/*********************************************************************
 * Module Name: Word to Block Assembler
 *              Block to Word Disassembler
 *
 * Synchronous device which packs BSIZE/WSIZE words into BSIZE'd 
 * data blocks to prepare data for processing by a block-oriented
 * device. Uses independent signalling to insert words and remove
 * blocks. Fully buffered with capability to store some data while
 * blocking together. Can be attached to and feed a synchronous 
 * device using the read_block and output_hold control signals.
 *
 * Parameters:
 * WSIZE: Input word size
 * BSIZE: Output block size
 * 
 * Considerations: 
 * - The logarithm of both word size and block size should 
 *   be an integer.
 * - Number of words should be a multiple of the number of blocks.
 *
 * Port Descriptions:
 * word_in: Word to insert into the block converter
 * 
 * block_out:      Output block data port.
 * read_block:     Signals the block converter to retrieve a block 
 *                 from the buffer and present it on the output port.
 * word_in_ready:  Indicates to the block device that the word is ready.
 * block_out_hold: Holds the blocking device until the controlling 
 *                 device is ready.
 ********************************************************************/
module word_to_block_assembler #(parameter WSIZE = 32, parameter BSIZE = WSIZE * 4)
    (
    input [WSIZE-1:0] word_in,
    input word_in_ready,
    input block_out_hold,
    output [BSIZE-1:0] block_out,
    output block_ready,
    output pull_word,
    input clock,
    input reset
    );
    reg  [WSIZE - 1:0] reg3, reg2, reg1, reg0; // Intermediate registers
    reg [2:0] count;
    
    initial begin
        count = 3'd0;
    end

    always @(posedge clock, posedge reset) begin
        if (count == 3'd4) begin
            count = 3'd0;
        end
        if(reset == 1) begin
            count <=  2'd0;
            reg0  <= 32'b0;
            reg1  <= 32'b0;
            reg2  <= 32'b0;
            reg3  <= 32'b0;           
        end
        else if (word_in_ready && pull_word) begin
            //regs[count] = word_in;
            case (count)
                2'd3: reg3 = word_in;
                2'd2: reg2 = word_in;
                2'd1: reg1 = word_in;
                2'd0: reg0 = word_in;
            endcase
            count = count + 1;
        end
    end
    
    assign pull_word = ~block_out_hold;
    assign block_ready = count == 3'd4;
    assign block_out[127:0] = { reg0, reg1, reg2, reg3 };
endmodule

module block_to_word_disassembler #(parameter WSIZE = 32, parameter BSIZE = WSIZE * 4)
    (
    input [BSIZE-1:0] block_in,
    input block_in_ready,
    input word_out_hold,
    output [WSIZE-1:0] word_out,
    output word_ready,
    output pull_block,
    input clock,
    input reset
    );
    
    parameter PULL_BLOCK = 1'b1;
    parameter HOLD_BLOCK = 1'b0;
    parameter WORD_READY = 1'b1;
    parameter WORD_NOT_READY = 1'b0;
    
    reg  [WSIZE - 1:0] regs[3:0]; // Intermediate registers
    reg [1:0] count;
    reg pull_state;
    
    initial begin
        count <= 2'd0;
    end

    always @(posedge clock, posedge reset) begin
        if (reset == 1'b1) begin
            count   <= 2'd0;
            regs[0] <= 1'b0;
            regs[1] <= 1'b0;
            regs[2] <= 1'b0;
            regs[3] <= 1'b0;
        end
        else begin
            if (block_in_ready && pull_state == PULL_BLOCK) begin
                { regs[0], regs[1], regs[2], regs[3] } <= block_in;
                pull_state <= HOLD_BLOCK;
                //word_ready <= 1'd1;
            end
            else if (! word_out_hold) begin
                count <= count + 1;
            end
        end
    end
    
    always @(word_out_hold, count) begin
        pull_state = ~word_out_hold & count == 2'd0;
    end
    
    assign word_out = regs[count];
    assign pull_block = pull_state;
    assign word_ready = pull_state == PULL_BLOCK ? WORD_NOT_READY : WORD_READY;
endmodule

/*********************************************************************
 * Module Name: Word to QWord FIFO
 *
 * Instantiates a full duplex and configurable first in, first out
 * unit which stores a FIFOLEN fixed number of blocks of WSIZE. It
 * internally tracks the current positioning of the FIFO then spits
 * back the next block upon a get_next signal. This FIFO is capable 
 * of simultaneous read and write by separating ports and triggering
 * signals.
 *
 * NOTE: Potential for race condition exists on a simultaneous 
 * read/write from the same slot!
 *
 * Parameters:
 * WSIZE:   Word size
 * FIFOLEN: Total number of words (length) of the FIFO
 *
 * Port Descriptions:
 * write_data: Data to write into the FIFO
 * read_data :  to read out of the FIFO
 * trigger_write: Fires a write operation
 * trigger_read: Fires off a read
 ********************************************************************/
module fifo #(parameter WSIZE = 32, parameter FIFOLEN = 1024) (
    input wire [WSIZE - 1:0] data_in,
    output reg [WSIZE - 1:0] data_out,
    input write_en,
    input read_en,
    output fifo_full,
    output fifo_empty,
    input reset,
    input clock
    );
    /*
        Function ilog2
        
        Implements a simple logarithm since we're not using SystemVerilog
     */
    function integer ilog2;
        input [31:0] value;
        integer i;
        begin
            ilog2 = 0;
            for(i = 0; 2**i < value; i = i + 1)
                ilog2 = i + 1;
            end
    endfunction
    
    wire trigger_read, trigger_write;
    assign trigger_write = clock & write_en;
    assign trigger_read = clock & read_en;
    
    parameter ADDRLEN = ilog2(FIFOLEN);
    reg [ADDRLEN:0] read_addr;
    reg [ADDRLEN:0] write_addr;

    reg [WSIZE - 1:0] fifo_mem[FIFOLEN - 1:0]; // MSB used to tell if there's a word there or not

    always @(posedge trigger_write) begin
        if (trigger_write && !fifo_full && !reset) begin
            fifo_mem[write_addr[ADDRLEN - 1:0]] <= data_in;
            write_addr <= write_addr + 1;
        end
        else begin
            // Let the user pick it up via the signal wire
        end
    end
    
    always @(posedge trigger_read) begin
        if (trigger_read && !fifo_empty && !reset) begin
            data_out <= fifo_mem[read_addr[ADDRLEN - 1:0]];
            read_addr <= read_addr + 'd1;
        end
        else begin
            // Leave existing data on the output buffer, signal to clue the user
        end
    end
    
    always @(reset) begin
        read_addr  <= 'd0;
        write_addr <= 'd0;
    end
    
    assign fifo_empty = (write_addr - read_addr) == 0;
    assign fifo_full  = (write_addr - read_addr) == FIFOLEN;
endmodule
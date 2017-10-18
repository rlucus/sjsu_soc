`timescale 1ns / 1ps


/*********************************************************************
 * Module Name: Word to Block Vonverter
 *
 * Asynchronous device which packs BSIZE/WSIZE words into BSIZE'd 
 * data blocks to prepare data for processing by a block-oriented
 * device. Uses independent signalling to insert words and remove
 * blocks. Fully buffered with capability to store some data while
 * blocking together. Can be attached to and feed a synchronous 
 * device using the read_block and output_hold control signals.
 *
 * Parameters:
 * WSIZE: Input word size
 * BSIZE: Output block size
 * NWD  : Number of words to buffer
 * NBK  : Number of blocks to buffer
 * 
 * Considerations: 
 * - The logarithm of both word size and block size should 
 *   be an integer.
 * - Number of words should be a multiple of the number of blocks.
 *
 * Port Descriptions:
 * word_in: Word to insert into the block converter
 * send_word: Signals to block converter that external port is 
 *            sending data into the device.
 * input_hold: Indicates that the block device is full and the 
 *             attached device must wait before sending more data.
 *
 * block_out: Output block data port
 * read_block: Signals the block converter to retrieve a block from
 *             the buffer and present it on the output port.
 * output_hold: Indicates that the block device is not ready to 
 *              output data.
 ********************************************************************/
module word_to_block_converter #(parameter WSIZE = 32, 
        parameter BSIZE = 256, 
        parameter NWD = 512, // These defaults correspond to symmetric buffers when word/block size is considered
        parameter NBL = 64) (
    input [WSIZE-1:0] word_in,
    input send_word,
    output input_hold,
    output [BSIZE-1:0] block_out,
    input read_block,
    output output_hold,
    input clock,
    input reset
    );
    parameter WPERB = BSIZE / WSIZE;
    
    wire word_fifo_full, word_fifo_empty, block_fifo_full, block_fifo_empty;
    wire trigger_word_read;
    wire trigger_block_write;
    wire [WSIZE - 1:0] transfer_word;
    reg  [BSIZE - 1:0] transfer_block;
    
    reg [WPERB - 1:0] count; // I know this is wastefully large and badly thought out, but whatever
    reg block_write_clock;
    
    assign trigger_word_read = clock & !word_fifo_full;
    assign trigger_word_write = block_write_clock & !block_fifo_full;
    
    assign input_hold = word_fifo_full | block_fifo_full;
    assign output_hold = block_fifo_empty;
    
    fifo #(.WSIZE(WSIZE), .FIFOLEN(NWD)) word_buffer(
        .write_data(word_in),
        .read_data(transfer_word),
        .trigger_write(send_word),
        .trigger_read(trigger_word_read),
        .reset(reset),
        .fifo_full(word_fifo_full),
        .fifo_empty(word_fifo_empty)
    );
    fifo #(.WSIZE(BSIZE), .FIFOLEN(NBL)) block_buffer(
        .write_data(transfer_block),
        .read_data(output_block),
        .trigger_write(trigger_block_write),
        .trigger_read(read_block),
        .reset(reset),
        .fifo_full(block_fifo_full),
        .fifo_empty(block_fifo_empty)
    );
    initial begin
        count = 'd0;
        block_write_clock = 'b0;
    end
    // To-do: make sure this actually translates data from transfer_word and transfer_block
    always @(trigger_word_read) begin
        transfer_block = transfer_block >> WSIZE;
        transfer_block[BSIZE - 1:WSIZE] = transfer_word;
        
        if (count >= WPERB) begin
            count = 'd0;
            block_write_clock = 'b1;
            #1 block_write_clock = 'b0;
        end
        else begin
            count = count + 1;
        end
    end
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
    input wire [WSIZE - 1:0] write_data,
    output reg [WSIZE - 1:0] read_data,
    input trigger_write,
    input trigger_read,
    input reset,
    output fifo_full,
    output fifo_empty
    );
    wire test;
    
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
    
    parameter ADDRLEN = ilog2(FIFOLEN);
    reg [ADDRLEN:0] read_addr;
    reg [ADDRLEN:0] write_addr;

    reg [WSIZE - 1:0] fifo_mem[FIFOLEN - 1:0]; // MSB used to tell if there's a word there or not

    always @(posedge trigger_write) begin
        if (trigger_write && !fifo_full && !reset) begin
            fifo_mem[write_addr[ADDRLEN - 1:0]] <= write_data;
            write_addr <= write_addr + 1;
        end
        else begin
            // Let the user pick it up via the signal wire
        end
    end
    
    always @(posedge trigger_read) begin
        if (trigger_read && !fifo_empty && !reset) begin
            read_data <= fifo_mem[read_addr[ADDRLEN - 1:0]];
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
    
    //assign fifo_empty = read_addr[ADDRLEN - 1:0] ^ write_addr[ADDRLEN - 1:0] ?
    //    'b0 : write_addr[ADDRLEN] ^ read_addr[ADDRLEN];
    //assign fifo_full  = read_addr[ADDRLEN - 1:0] ^ write_addr[ADDRLEN - 1:0] ?
    //    'b0 : write_addr[ADDRLEN] ^ read_addr[ADDRLEN];
    assign fifo_empty = (write_addr - read_addr) == 0;
    assign fifo_full  = (write_addr - read_addr) == FIFOLEN;
    assign test = read_addr[ADDRLEN - 1:0] & write_addr[ADDRLEN - 1:0];
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2017 12:40:32 PM
// Design Name: 
// Module Name: aes256_datapath
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

/*********************************************************************************
 * AES-256 Datapath
 * 
 * Author: Kai Wetlesen
 * 
 * Constructs a data path which allows a typical MIPS processor to implement 
 * AES-256 as a co-processor with some minor wrapping.
 *
 * Create Date: 22/10/2017 12:40 PM
 * 
 * Project Name: Accelerated SoC
 *********************************************************************************/


module aes256_datapath(
    input [127:0] key_datain,
    input setkey_ctrin,
    input [127:0] nonce_datain,
    input setnonce_ctrin,
    input run_ctrin,
    input [31:0] user_datain,
    input wren_ctrin,
    input rden_ctrin,
    output [31:0] user_dataout,
    output outwordfifoempty_ctrout,
    output outwordfifofull_ctrout,
    output inblockfifoempty_ctrout,
    output inblockfifofull_ctrout,
    output inwordfifoempty_ctrout,
    output inwordfifofull_ctrout,
    output outblockfifoempty_ctrout,
    output outblockfifofull_ctrout,
    input clock,
    input reset
    );
    parameter FIFOLEN = 32;
    parameter IWFL = FIFOLEN; // Input word FIFO length
    parameter IBFL = FIFOLEN; // Input block FIFO length
    parameter OWFL = FIFOLEN; // Output word FIFO length
    parameter OBFL = FIFOLEN; // Output block FIFO length
    parameter WSIZE = 32;
    parameter BSIZE = 128;
    
    /*
        Note about intra-device naming conventions:
        Some of these names are stupidly long (like inwordfifo),
        so where a wire bridges two devices I take the first initials
        of the device names and join them with "to" in order to 
        indicate where the wire originates from and what it hooks to. 
        After, I append the driving signal name (minus underscores) 
        for traceability
        
        Ex: iwf_to_wtba_wren - Input Word FIFO to Word To Block Assembler Write Enable
    */
    
    /* KEY STATE AND MAINTENANCE LOGIC */
    /* Internal signals */
    /* Internal storage */
    reg [255:0] key;
    reg [127:0] cur_state;
    always @(posedge clock, posedge reset) 
        if (reset)
            key <= 256'b0;
        else if(setkey_ctrin == 1'b1)
            key <= key_datain;
        else
            key <= key;
        
    always @(posedge clock, posedge reset) 
        if (reset) begin
            cur_state <= 128'b0;
        end
        else begin
            if (setnonce_ctrin == 1'b1)
                cur_state <= nonce_datain;
            else if (run_ctrin == 1'b0) // Hold state if not run
                cur_state <= cur_state;
            else
                cur_state <= cur_state + 1;
        end
    
    /* LEAD-IN BUFFERING LOGIC */
    
    /* Internal signals relevant to lead-in buffering*/
    wire [31:0] iwf_to_wtba_dataout;
    wire [127:0] wtba_to_ibf_blockout, ibf_to_mainxor_dataout;
    wire wtba_to_iwf_pullword;
    wire wtba_to_ibf_blockready;
            
    wire [200:0] TBD;   

    fifo #(.WSIZE(WSIZE), .FIFOLEN(IWFL))
        inwordfifo (
            .data_in(user_datain), .data_out(iwf_to_wtba_dataout),
            .write_en(wren_ctrin), .read_en(wtba_to_iwf_pullword),
            .fifo_full(inwordfifofull_ctrout), .fifo_empty(inwordfifoempty_ctrout),
            .clock(clock), .reset(reset)
        );
    
    word_to_block_assembler #(.WSIZE(WSIZE), .BSIZE(BSIZE))
        wtb_assembler (
            .word_in(iwf_to_wtba_dataout), .block_out(wtba_to_ibf_blockout),
            .word_in_ready(~inwordfifoempty_ctrout), .block_out_hold(outblockfifofull_ctrout),
            .block_ready(wtba_to_ibf_blockready), .pull_word(wtba_to_iwf_pullword),
            .clock(clock), .reset(reset)
        );
    
    fifo #(.WSIZE(BSIZE), .FIFOLEN(IBFL))
        inblockfifo (
            .data_in(wtba_to_ibf_blockout), .data_out(ibf_to_main_xor_dataout),
            .write_en(wtba_to_ibf_blockready), .read_en(run_ctrin),
            .fifo_full(inblockfifofull_ctrout), .fifo_empty(inblockfifoempty_ctrout),
            .clock(clock), .reset(reset)
        );
    
endmodule

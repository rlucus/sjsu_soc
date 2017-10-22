`timescale 1ns / 1ps

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
 * 
 * To-Do:
 *  - IMPLEMENT HOLD AND RESET ON AES
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
    
    /* KEY AND STATE MAINTENANCE LOGIC */
    /* Internal storage */
    reg [255:0] key;
    reg [127:0] cur_state;
    /* Key Register */
    always @(posedge clock, posedge reset) 
        if (reset)
            key <= 256'b0;
        else if(setkey_ctrin == 1'b1)
            key <= key_datain;
        else
            key <= key;

    /* State Register */   
    /*
        Note: This is NOT a controlling state machine! This device only
        maintains the current state output by the AES state generator.
    */
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
    
    /* AES-256 STATE ENGINE */
    /* Internal signals relevant to the AES module */
    wire [127:0] ase_to_mainxor_out;
    aes_256
        aes_state_engine ( // A.K.A ase 
            .state(cur_state), .out(ase_to_mainxor_out),
            .key(key),
            // .hold(hold),
            .clk(clock) //, .reset(reset)
        );
    
    /* LEAD-IN BUFFERING LOGIC */
    /* Internal signals relevant to lead-in buffering*/
    wire [31:0] iwf_to_wtba_dataout;
    wire [127:0] wtba_to_ibf_blockout, ibf_to_mainxor_dataout;
    wire wtba_to_iwf_pullword;
    wire wtba_to_ibf_blockready;
    
    wire wtba_blockready_logic;
    
    assign wtba_blockready_logic = ~inwordfifoempty_ctrout;

    fifo #(.WSIZE(WSIZE), .FIFOLEN(IWFL))
        inwordfifo ( // A.K.A. iwf
            .data_in(user_datain), .data_out(iwf_to_wtba_dataout),
            .write_en(wren_ctrin), .read_en(wtba_to_iwf_pullword),
            .fifo_full(inwordfifofull_ctrout), .fifo_empty(inwordfifoempty_ctrout),
            .clock(clock), .reset(reset)
        );
    
    word_to_block_assembler #(.WSIZE(WSIZE), .BSIZE(BSIZE))
        wtb_assembler ( // A.K.A. wtba
            .word_in(iwf_to_wtba_dataout), .block_out(wtba_to_ibf_blockout),
            .word_in_ready(wtba_blockready_logic), .block_out_hold(outblockfifofull_ctrout),
            .block_ready(wtba_to_ibf_blockready), .pull_word(wtba_to_iwf_pullword),
            .clock(clock), .reset(reset)
        );
    
    fifo #(.WSIZE(BSIZE), .FIFOLEN(IBFL))
        inblockfifo ( // A.K.A. ibf
            .data_in(wtba_to_ibf_blockout), .data_out(ibf_to_mainxor_dataout),
            .write_en(wtba_to_ibf_blockready), .read_en(run_ctrin),
            .fifo_full(inblockfifofull_ctrout), .fifo_empty(inblockfifoempty_ctrout),
            .clock(clock), .reset(reset)
        );
        
    /* MAIN XOR */
    /* Internal signals related to the main XOR gate */
    wire [127:0] mainxor_to_obf_out;
    
    assign mainxor_to_obf_out = ase_to_mainxor_out ^ ibf_to_mainxor_dataout;
    
    /* LEAD OUT BUFFERING LOGIC */
    /* Internal signals related to output buffering logic */
    wire [127:0] obf_to_btwd_dataout;
    wire [31:0] btwd_to_obf_wordout;
    wire btwd_to_obf_pullblock;
    wire btwd_to_owf_wordready;
    
    wire obf_wren_logic;
    wire btwd_blockinready_logic;
    
    assign obf_wren_logic = run_ctrin & ~inblockfifoempty_ctrout;
    assign btwd_blockinready_logic = ~outblockfifoempty_ctrout;
    
    fifo #(.WSIZE(BSIZE), .FIFOLEN(OBFL))
        outblockfifo ( // A.K.A. obf
            .data_in(mainxor_to_obf_out), .data_out(obf_to_btwd_dataout),
            .write_en(obf_wren_logic), .read_en(btwd_to_obf_pullblock),
            .fifo_full(outblockfifofull_ctrout), .fifo_empty(outblockfifoempty_ctrout),
            .clock(clock), .reset(reset)
        );
    
    block_to_word_disassembler #(.BSIZE(BSIZE), .WSIZE(WSIZE))
        btw_disassembler ( // A.K.A. btwd
            .block_in(obf_to_btwd_dataout), .word_out(btwd_to_owf_wordout),
            .block_in_ready(btwd_blockinready_logic), .word_out_hold(IN),
            .word_ready(OUT), .pull_block(btwd_to_obf_pullblock)
        );
    
    fifo #(.WSIZE(WSIZE), .FIFOLEN(OWFL))
        outwordfifo ( // A.K.A. owf
            .data_in(btwd_to_owf_wordout), .data_out(user_dataout),
            .write_en(btwd_to_owf_wordready), .read_en(rden_ctrin),
            .fifo_full(outwordfifofull_ctrout), .fifo_empty(outwordfifoempty_ctrout),
            .clock(clock), .reset(reset)
        );
endmodule

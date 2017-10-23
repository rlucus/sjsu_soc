`timescale 1ns / 1ps

/*********************************************************************************
 * AES-256 Co-Processor
 * 
 * Author: Kai Wetlesen
 * 
 * Constructs a co-processor which interfaces with MIPS through an available
 * co-processor socket.
 *
 * Create Date: 22/10/17 17:08
 * 
 * Project Name: Accelerated SoC
 *********************************************************************************/
module aes256_coprocessor(
    input [31:0] data_in,
    input [3:0] addr,
    input write_en,
    output reg [31:0] data_out,
    input clock,
    output interrupt
    );
    reg [31:0] status;
    reg [31:0] nonce_in [3:0];
    reg [31:0] key_in [7:0];
    
    wire [7:0] status_aggregate;
    wire [255:0] key_aggregate;
    wire [127:0] nonce_aggregate;
    
    reg  [31:0] aes256_to_outmux_userdatain;
    wire [31:0] aes256_to_outmux_userdataout;
    
    reg setkey;
    reg setnonce;
    reg wren;
    reg rden;
    
    assign interrupt = 1'b0;
    
    aes256_datapath aes256 (
        .key_datain(key_aggregate),
        .setkey_ctrin(setkey),
        .nonce_datain(nonce_aggregate),
        .setnonce_ctrin(setnonce),
        .run_ctrin(status[0]),
        .user_datain(aes256_to_outmux_userdatain),
        .wren_ctrin(wren),
        .rden_ctrin(rden),
        .user_dataout(aes256_to_outmux_userdataout),
        .inwordfifoempty_ctrout(status_aggregate[7]),
        .inwordfifofull_ctrout(status_aggregate[6]),
        .inblockfifoempty_ctrout(status_aggregate[5]),
        .inblockfifofull_ctrout(status_aggregate[4]),
        .outwordfifoempty_ctrout(status_aggregate[3]),
        .outwordfifofull_ctrout(status_aggregate[2]),
        .outblockfifoempty_ctrout(status_aggregate[1]),
        .outblockfifofull_ctrout(status_aggregate[0]),
        .clock(clock),
        .reset(status[1])
        );
    assign key_aggregate = {key_in[7], key_in[6], key_in[5], key_in[4], key_in[3], key_in[2], key_in[1], key_in[0]};
    assign nonce_aggregate = {nonce_in[3], nonce_in[2], nonce_in[1], nonce_in[0]};
    
    always @(status_aggregate) begin
        status[31:24] <= status_aggregate;
        status[23:2] = 22'b0;
    end
    
    always @(addr, write_en)
        if (write_en == 1'b1)
            case (addr)
                31'd00: {setkey, setnonce, wren, rden} = 4'b0000;
                31'd01: {setkey, setnonce, wren, rden} = 4'b0100;
                31'd02: {setkey, setnonce, wren, rden} = 4'b0100;
                31'd03: {setkey, setnonce, wren, rden} = 4'b0100;
                31'd04: {setkey, setnonce, wren, rden} = 4'b0100;
                31'd05: {setkey, setnonce, wren, rden} = 4'b1000;
                31'd06: {setkey, setnonce, wren, rden} = 4'b1000;
                31'd07: {setkey, setnonce, wren, rden} = 4'b1000;
                31'd08: {setkey, setnonce, wren, rden} = 4'b1000;
                31'd09: {setkey, setnonce, wren, rden} = 4'b1000;
                31'd10: {setkey, setnonce, wren, rden} = 4'b1000;
                31'd11: {setkey, setnonce, wren, rden} = 4'b1000;
                31'd12: {setkey, setnonce, wren, rden} = 4'b0010;
                31'd13: {setkey, setnonce, wren, rden} = 4'b0001;
                default: {setkey, setnonce, wren, rden} = 4'b0000;
            endcase
        else
            {setkey, setnonce, wren, rden} = 4'b0000;
    
    always @(posedge clock)
        if (write_en == 1'b1)
            case (addr)
                31'd00: status[1:0] <= data_in[1:0];
                31'd01: nonce_in[0] <= data_in;
                31'd02: nonce_in[1] <= data_in;
                31'd03: nonce_in[2] <= data_in;
                31'd04: nonce_in[3] <= data_in;
                31'd05: key_in[0] <= data_in;
                31'd06: key_in[1] <= data_in;
                31'd07: key_in[2] <= data_in;
                31'd08: key_in[3] <= data_in;
                31'd09: key_in[4] <= data_in;
                31'd10: key_in[5] <= data_in;
                31'd11: key_in[6] <= data_in;
                31'd12: key_in[7] <= data_in;
                31'd13: aes256_to_outmux_userdatain <= data_in;
                // default do nothing                
            endcase
    
    always @(addr, status, nonce_in, key_in, aes256_to_outmux_userdatain, aes256_to_outmux_userdataout)
        case (addr)
            31'd00: data_out <= status;
            31'd01: data_out <= nonce_in[0];
            31'd02: data_out <= nonce_in[1];
            31'd03: data_out <= nonce_in[2];
            31'd04: data_out <= nonce_in[3];
            31'd05: data_out <= key_in[0];
            31'd06: data_out <= key_in[1];
            31'd07: data_out <= key_in[2];
            31'd08: data_out <= key_in[3];
            31'd09: data_out <= key_in[4];
            31'd10: data_out <= key_in[5];
            31'd11: data_out <= key_in[6];
            31'd12: data_out <= key_in[7];
            31'd13: data_out <= aes256_to_outmux_userdatain;
            31'd14: data_out <= aes256_to_outmux_userdataout;
            default: data_out <= 31'b0;
        endcase
endmodule
    


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
    input [255:0] key_datain,
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
//btwd_to_owf_wordready
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
    wire [31:0] btwd_to_owf_wordout;
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
            .block_in_ready(btwd_blockinready_logic), .word_out_hold(outwordfifofull_ctrout),
            .word_ready(btwd_to_owf_wordready), .pull_block(btwd_to_obf_pullblock),
            .clock(clock), .reset(reset)
        );
    
    fifo #(.WSIZE(WSIZE), .FIFOLEN(OWFL))
        outwordfifo ( // A.K.A. owf
            .data_in(btwd_to_owf_wordout), .data_out(user_dataout),
            .write_en(btwd_to_owf_wordready), .read_en(rden_ctrin),
            .fifo_full(outwordfifofull_ctrout), .fifo_empty(outwordfifoempty_ctrout),
            .clock(clock), .reset(reset)
        );
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Modified from the Digilent sample programs using the oLED SPI Screen
// -This module uses the oLED screen on the Nexys Video board to 
//  display the values passed by the mips processor for the 
//  program counter and the current instruction
// 
// 
////// IMPORTANT: OPERATING THE SCREEN ////////
// YOU MUST TURN OFF THE SCREEN BEFORE POWERING OFF THE BOARD!!!
// 
// -The default state of the screen in ON for boot
// -The CPU_RESET button is the default button for the screen ON/OFF
// -When powering off the board, the screen MUST be in the off state of 
//  damage may occur
// 
//////////////////////////////////////////////////////////////////////////////////

module spiScreen(
    input clk,
    input rstn,// CPU Reset Button turns the display on and off
//    input [31:0] pc, instr,
    output oled_sdin,
    output oled_sclk,
    output oled_dc,
    output oled_res,
    output oled_vbat,
    output oled_vdd,
//    output oled_cs,
    output [7:0] led
);
////////////// STANDALONE STUFF ///////////////
// To run this without a top level module
//   - uncomment this block
//   - comment line 11, input [31:0] pc, instr
//////////////
    reg [ 31:0] pc       = 0;   // SWAP for input if not standalone
    reg [ 31:0] instr    = 0;
    reg [ 14:0] counter  = 0;
    always @ (posedge clk) begin
        counter = counter + 1;
        if (counter >10000) begin
            pc = pc + 1;
            instr = instr + 1;
            counter = 0;
        end     
    end 
////////////// END STANDALONE STUFF ///////////////


    //state machine codes
    localparam Idle       = 0;
    localparam Init       = 1;
    localparam Active     = 2;
    localparam Done       = 3;
    localparam FullDisp   = 4;
    localparam Write      = 5;
    localparam WriteWait  = 6;
    localparam UpdateWait = 7;
    
    //text to be displayed
    localparam str1="   ARK-J SoC    ", str1len=16;
    localparam str2="                ", str2len=16;
    
    //state machine registers.
    reg [2:0] state = Init;//initialize the oled display on demo startup
    reg [5:0] count = 0;   //loop index variable
    reg       once  = 0;   //bool to see if we have set up local pixel memory in this session

        
    //oled control signals
    //command start signals, assert high to start command
    reg        update_start      = 0;   //update oled display over spi
    reg        disp_on_start     = 1;   //turn the oled display on
    reg        disp_off_start    = 0;   //turn the oled display off
    reg        toggle_disp_start = 0;   //turns on every pixel on the oled, or returns the display to before each pixel was turned on
    reg        write_start       = 0;   //writes a character bitmap into local memory
    
    //data signals for oled controls
    reg        update_clear     = 0;    //when asserted high, an update command clears the display, instead of filling from memory
    reg  [8:0] write_base_addr  = 0;    //location to write character to, two most significant bits are row position, 0 is topmost. bottom seven bits are X position, addressed by pixel x position.
    reg  [7:0] write_ascii_data = 0;    //ascii value of character to write to memory
    
    //active high command ready signals, appropriate start commands are ignored when these are not asserted high
    wire       disp_on_ready;
    wire       disp_off_ready;
    wire       toggle_disp_ready;
    wire       update_ready;
    wire       write_ready;
    
    //debounced button signals used for state transitions
    wire       rst;     // CPU RESET BUTTON turns the display on and off, on display_on, local memory is filled from string parameters

    reg [127:0] out_pc, out_inst;                    
    reg [ 63:0] num_pc   = 0;
    reg [ 63:0] num_inst = 0;  

    
    OLEDCtrl uut (
        .clk                (clk),              
        .write_start        (write_start),      
        .write_ascii_data   (write_ascii_data), 
        .write_base_addr    (write_base_addr),  
        .write_ready        (write_ready),      
        .update_start       (update_start),     
        .update_ready       (update_ready),     
        .update_clear       (update_clear),    
        .disp_on_start      (disp_on_start),    
        .disp_on_ready      (disp_on_ready),    
        .disp_off_start     (disp_off_start),   
        .disp_off_ready     (disp_off_ready),   
        .toggle_disp_start  (toggle_disp_start),
        .toggle_disp_ready  (toggle_disp_ready),
        .SDIN               (oled_sdin),        
        .SCLK               (oled_sclk),        
        .DC                 (oled_dc  ),        
        .RES                (oled_res ),        
        .VBAT               (oled_vbat),        
        .VDD                (oled_vdd )
    );
//    assign oled_cs = 1'b0;

    always@(write_base_addr)
        case (write_base_addr[8:7])//select string as [y]
        0: write_ascii_data <= 8'hff & (str1 >> ({3'b0, (str1len - 1 - write_base_addr[6:3])} << 3));//index string parameters as str[x]
        1: write_ascii_data <= 8'hff & (str2 >> ({3'b0, (str2len - 1 - write_base_addr[6:3])} << 3));
        2: write_ascii_data <= 8'hff & (out_pc   >> ({3'b0, (str2len - 1 - write_base_addr[6:3])} << 3));
        3: write_ascii_data <= 8'hff & (out_inst >> ({3'b0, (str2len - 1 - write_base_addr[6:3])} << 3));
        endcase


    //debouncers ensure single state machine loop per button press. noisy signals cause possibility of multiple "positive edges" per press.
    debouncer #(
        .COUNT_MAX(65535),
        .COUNT_WIDTH(16)
    )  get_rstn (
        .clk(clk),
        .A(~rstn),
        .B(rst)
    );
    
    always @ (pc) begin
        num_pc[ 7: 0] <= (pc[ 3: 0]>=10) ? {4'h4, (pc[ 3: 0]-4'h9) } : {4'h3, pc[ 3: 0]} ;
        num_pc[15: 8] <= (pc[ 7: 4]>=10) ? {4'h4, (pc[ 7: 4]-4'h9) } : {4'h3, pc[ 7: 4]} ;        
        num_pc[23:16] <= (pc[11: 8]>=10) ? {4'h4, (pc[11: 8]-4'h9) } : {4'h3, pc[11: 8]} ;        
        num_pc[31:24] <= (pc[15:12]>=10) ? {4'h4, (pc[15:12]-4'h9) } : {4'h3, pc[15:12]} ;     
        num_pc[39:32] <= (pc[19:16]>=10) ? {4'h4, (pc[19:16]-4'h9) } : {4'h3, pc[19:16]} ;
        num_pc[47:40] <= (pc[23:20]>=10) ? {4'h4, (pc[23:20]-4'h9) } : {4'h3, pc[23:20]} ;        
        num_pc[55:48] <= (pc[27:24]>=10) ? {4'h4, (pc[27:24]-4'h9) } : {4'h3, pc[27:24]} ;        
        num_pc[63:56] <= (pc[31:28]>=10) ? {4'h4, (pc[31:28]-4'h9) } : {4'h3, pc[31:28]} ;           
        out_pc = {56'h5043_3a20_3a20_20, num_pc[63:32], 8'h5f , num_pc[31: 0] };
    end
    
    always @ (instr) begin
        num_inst[ 7: 0] <= (instr[ 3: 0]>=10) ? {4'h4, (instr[ 3: 0]-4'h9) } : {4'h3, instr[ 3: 0]} ;
        num_inst[15: 8] <= (instr[ 7: 4]>=10) ? {4'h4, (instr[ 7: 4]-4'h9) } : {4'h3, instr[ 7: 4]} ;        
        num_inst[23:16] <= (instr[11: 8]>=10) ? {4'h4, (instr[11: 8]-4'h9) } : {4'h3, instr[11: 8]} ;        
        num_inst[31:24] <= (instr[15:12]>=10) ? {4'h4, (instr[15:12]-4'h9) } : {4'h3, instr[15:12]} ;     
        num_inst[39:32] <= (instr[19:16]>=10) ? {4'h4, (instr[19:16]-4'h9) } : {4'h3, instr[19:16]} ;
        num_inst[47:40] <= (instr[23:20]>=10) ? {4'h4, (instr[23:20]-4'h9) } : {4'h3, instr[23:20]} ;        
        num_inst[55:48] <= (instr[27:24]>=10) ? {4'h4, (instr[27:24]-4'h9) } : {4'h3, instr[27:24]} ;        
        num_inst[63:56] <= (instr[31:28]>=10) ? {4'h4, (instr[31:28]-4'h9) } : {4'h3, instr[31:28]} ; 
        out_inst = {56'h496e_7374_3a20_20, num_inst[63:32], 8'h5f , num_inst[31: 0] }; 
    end     
    
    assign led = update_ready; //display whether btnU, BtnD controls are available.
    assign init_done = disp_off_ready | toggle_disp_ready | write_ready | update_ready;//parse ready signals for clarity
    assign init_ready = disp_on_ready;
    always@(posedge clk)
        case (state)
            Idle: begin
                if (rst == 1'b1 && init_ready == 1'b1) begin
                    disp_on_start <= 1'b1;
                    state <= Init;
                end
                once <= 0;
            end
            Init: begin
                disp_on_start <= 1'b0;
                if (rst == 1'b0 && init_done == 1'b1)
                    state <= Active;
            end
            Active: begin // hold until ready, then accept input
                if (rst && disp_off_ready) begin
                    disp_off_start <= 1'b1;
                    state <= Done;
                end else if (once == 0 && write_ready) begin
                    write_start <= 1'b1;
                    write_base_addr <= 'b0;
//                    write_ascii_data <= 8'd65;
                    state <= WriteWait;
                end else if (once == 1) begin
                    update_start <= 1'b1;
                    update_clear <= 1'b0;
                    once = 0;
                    state <= UpdateWait;
                end
            end
            Write: begin
                write_start <= 1'b1;
                write_base_addr <= write_base_addr + 9'h8;
                //write_ascii_data updated with write_base_addr
                state <= WriteWait;
            end
            WriteWait: begin
                write_start <= 1'b0;
                if (write_ready == 1'b1)
                    if (write_base_addr == 9'h1f8) begin
                        once <= 1;
                        state <= Active;
                    end else begin
                        state <= Write;
                    end
            end
            UpdateWait: begin
                update_start <= 0;
                if (init_done == 1'b1)
                    state <= Active;
            end
            Done: begin
                disp_off_start <= 1'b0;
                if (rst == 1'b0 && init_ready == 1'b1)
                    state <= Idle;
            end
            default: state <= Idle;
        endcase
endmodule

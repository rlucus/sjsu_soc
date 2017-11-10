module mux2 #(parameter wide = 8)
(input sel, [wide-1:0] a, b, output [wide-1:0] y);
    assign y = sel ? b : a;
endmodule

module mux4 #(parameter wide = 8)
(input [1:0] sel, [wide-1:0] a, b, c, d, output reg [wide-1:0] y);
    always @ (sel, a, b, c, d)
    begin
        case(sel)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
            2'b11: y = d;
        endcase
    end
endmodule

module adder #(parameter wide = 8)
(input [wide-1:0] a, b, output [wide-1:0] y);
    assign y = a + b;
endmodule

module multi #(parameter wide = 8)
(input [wide-1:0] a, b, output [wide-1:0] h, l);
    assign {h, l} = a * b;
endmodule

module signext
(input [15:0] a, output [31:0] y);
    assign y = {{16{a[15]}}, a};
endmodule

module alu #(parameter wide = 8)
(input [3:0] op, [wide-1:0] a, b, [4:0] shiftamount, output zero, NE, reg trap, reg [wide-1:0] y);
    assign zero = (y == 'h0);
    assign NE = (a != b);
    always @ (op, a, b)
        case (op)
            4'b0000: begin y = a & b; trap = 0; end
            4'b0001: begin y = a | b; trap = 0; end
            4'b0010: begin y = a + b; trap = 0; end
            4'b0011: begin y = ~(a | b); trap = 0; end//NOR
            4'b0100: begin y = b << shiftamount; trap = 0; end//SLL
            4'b0101: begin y = b >> shiftamount; trap = 0; end//SRL
            4'b0110: begin y = a - b; trap = 0; end
            4'b0111: begin y = (a < b) ? 1 : 0; trap = 0; end
            4'b1000: begin y = b >>> shiftamount; trap = 0; end//SRA
            4'b1001: begin y = a ^ b; trap = 0; end//XOR
            4'b1010: if(a != b) trap = 1'b1;
            4'b1011: if(a == b) trap = 1'b1;
            default: y = 'hx;
        endcase
endmodule

module dreg #(parameter wide = 8)
(input clk, rst, en, [wide-1:0] d, output reg [wide-1:0] q);
    always @ (posedge clk, posedge rst)
    begin
        if (rst) q <= 0;
        else     q <= en ? d : q;
    end
endmodule

module regfile #(parameter wide = 8)
(input clk, we, [4:0] wa, ra1, ra2, [wide-1:0] wd, output [wide-1:0] rd1, rd2);
    reg [wide-1:0] rf [0:31];
    always @ (posedge clk) if (we) rf[wa] <= wd;
    assign rd1 = (ra1) ? rf[ra1] : 0;
    assign rd2 = (ra2) ? rf[ra2] : 0;
endmodule

module imem #(parameter wide = 8)
//(input [5:0] a, output [wide-1:0] y);
(input [31:0] a, output [wide-1:0] y);
    //reg [wide-1:0] rom [0:63];
    reg [wide-1:0] rom [0:400];
    initial $readmemh ("memfile.dat", rom);
    assign y = rom[(a/4)];
endmodule

module dmem #(parameter wide = 8)
(input clk, we, [5:0] a, [wide-1:0] d, output [wide-1:0] q);
    reg [wide-1:0] ram [0:63];
    always @ (posedge clk) if (we) ram[a] <= d;
    assign q = ram[a];
endmodule

module maindec
(input EXL, hold, IV, [5:0] op, funct, [4:0] cpop, [31:0] pc_current, output reg holdACK, branch, link, reg_dst, we_reg, alu_src, we_dm, dm2reg, weCP0, weCP2, BNE, INTCTRL, reg [1:0] prossSel, jump, reg [2:0] alu_op);
    reg [16:0] ctrl;
    always @ (ctrl) {branch, jump, link, reg_dst, we_reg, alu_src, we_dm, dm2reg, alu_op, prossSel, weCP0, weCP2, BNE} = ctrl;
    
    always @ (op)
    
        case(op)
            6'b000100: INTCTRL <= 1'b1;//BEQ
            6'b000010: INTCTRL <= 1'b1;//J
            6'b000011: INTCTRL <= 1'b1;//JAL
            6'b000101: INTCTRL <= 1'b1;//BNE
            6'b000000:
            begin
                if(funct == 6'b001000)
                begin
                    INTCTRL <= 1'b1;
                end
            end
            default: INTCTRL <= 1'b0;
        endcase
    
    always @ (op, EXL)
        //interrupt logic
        if((EXL == 1) & ((pc_current < 32'h180) | (pc_current > 32'h200)))
        begin
            ctrl[15:14] = IV ? 2'b11 : 2'b10; 
        end else 
        begin
            //put hold accept logic here
            if(hold) holdACK = hold ? 1'b1 : 1'b0;
            else begin
            case (op)
                6'b000000: ctrl = 17'b0_00_0_1_1_0_0_0_010_00_0_0_0; // R-Type
                6'b100011: ctrl = 17'b0_00_0_0_1_1_0_1_000_00_0_0_0; // LW
                6'b101011: ctrl = 17'b0_00_0_0_0_1_1_0_000_00_0_0_0; // SW
                6'b000100: ctrl = 17'b1_00_0_0_0_0_0_0_001_00_0_0_0; // BEQ
                6'b001000: ctrl = 17'b0_00_0_0_1_1_0_0_000_00_0_0_0; // ADDI
                6'b000010: ctrl = 17'b0_01_0_0_0_0_0_0_000_00_0_0_0; // J
                6'b000011: ctrl = 17'b0_01_1_0_1_0_0_0_000_00_0_0_0; // JAL
                6'b001010: ctrl = 17'b0_00_0_0_1_1_0_0_011_00_0_0_0; // SLTI, untested
                6'b000101: ctrl = 17'b0_00_0_0_0_0_0_0_001_00_0_0_1;//BNE
                6'b010000: //MFC0/MTC0
                    begin
                        if(cpop == 5'b00000)
                        begin
                            //MFC0
                            ctrl = 17'b0_00_0_0_1_0_0_0_000_01_0_0_0;
                        end else if(cpop == 5'b00100)
                        begin
                            //MTC0
                            ctrl = 17'b0_00_0_0_0_0_0_0_000_00_1_0_0;
                        end
                    end
                6'b010010: //MTC2/MFC2
                    begin
                        if(cpop == 5'b00000)
                        begin
                            //MFC2
                            ctrl = 17'b0_00_0_0_1_0_0_0_000_10_0_0_0;
                        end else if(cpop == 5'b00100)
                        begin
                            //MTC2
                            ctrl = 17'b0_00_0_0_0_0_0_0_000_00_0_1_0;
                        end
                    //end of MXC2
                    end
                default: ctrl = 17'bx;
            endcase
        //end of hold logic
        end
        //end of logic
        end
        
endmodule

module auxdec
(input [2:0] alu_op, [5:0] funct, output reg jump_reg, we_hi, we_lo, hi2reg, lo2reg, reg [3:0] alu_ctrl);
    reg [8:0] ctrl;
    //adjusting alucontrol
    always @ (ctrl) {jump_reg, we_hi, we_lo, hi2reg, lo2reg, alu_ctrl} = ctrl;
    always @ (alu_op, funct)
        case (alu_op)
            3'b000: ctrl = 9'b0_0_0_0_0_0010; // add
            3'b001: ctrl = 9'b0_0_0_0_0_0110; // sub
            3'b011: ctrl = 9'b0_0_0_0_0_0111; //SLTI
            3'b010: case (funct)
                6'b100000: ctrl = 9'b0_0_0_0_0_0010; // ADD
                6'b100010: ctrl = 9'b0_0_0_0_0_0110; // SUB
                6'b100100: ctrl = 9'b0_0_0_0_0_0000; // AND
                6'b100101: ctrl = 9'b0_0_0_0_0_0001; // OR
                6'b101010: ctrl = 9'b0_0_0_0_0_0111; // SLT
                6'b011001: ctrl = 9'b0_1_1_0_0_0000; // MULTU
                6'b010000: ctrl = 9'b0_0_0_1_0_0000; // MFHI
                6'b010010: ctrl = 9'b0_0_0_0_1_0000; // MFLO
                6'b001000: ctrl = 9'b1_0_0_0_0_0000; // JR
                6'b011011: ctrl = 9'b0_0_0_0_0_0011;//NOR
                6'b000000: ctrl = 9'b0_0_0_0_0_0100;//SLL
                6'b000010: ctrl = 9'b0_0_0_0_0_0101;//SRL
                6'b000011: ctrl = 9'b0_0_0_0_0_1000;//SRA
                6'b100110: ctrl = 9'b0_0_0_0_0_1001;//XOR
                6'b110110: ctrl = 9'b0_0_0_0_0_1010;//TNE
                6'b110100: ctrl = 9'b0_0_0_0_0_1011;//TEQ
                //6'b
                default: ctrl = 8'bx;
            endcase
        endcase
endmodule

module INTPC #(parameter location = 384) (input rst, clk, output [31:0] INTPC);

    reg [31:0] address = location;
    assign INTPC = address;
    always @ (posedge clk)
        if(rst == 0)
        begin
            address = location;
        end else
        begin
            address = address + 4;
        end

endmodule

//MODULES FOR HARDWARE

`timescale 1ns / 1ps

module clk_gen(input clk450MHz, input rst, output reg clk_sec);

integer count, count1;

always@(posedge clk450MHz)
    begin
        if(rst)
        begin
            count = 0;
            clk_sec = 0;
        end
        else
        begin
            //if(count == 50000000) /* 50e6 x 10ns = 1/2sec, toggle twice for 1sec */
            if(count == 604) /* 50e6 x 10ns = 1/2sec, toggle twice for 1sec */
            begin
            clk_sec = ~clk_sec;
            count = 0;
            end
            count = count + 1;
        end
    end
endmodule // end clk_gen


/* 7-segment values */
`define D0 8'b10001000 /* 0 */
`define D1 8'b11101101 /* 1 */
`define D2 8'b10100010 /* 2 */
`define D3 8'b10100100 /* 3 */
`define D4 8'b11000101 /* 4 */
`define D5 8'b10010100 /* 5 */
`define D6 8'b10010000 /* 6 */
`define D7 8'b10101101 /* 7 */
`define D8 8'b10000000 /* 8 */
`define D9 8'b10000100 /* 9 */
`define DA 8'b10100000 /* A */
`define DB 8'b11010000 /* B */
`define DC 8'b11110010 /* C */
`define DD 8'b11100000 /* D */
`define DE 8'b10010010 /* E */
`define DF 8'b10010011 /* F */
`define DX 8'b01111111 /* All segments off except decimal point */

/* Generate one decimal digits from a 4-bit number */
module bcd_to_7seg(input [3:0] num, output reg [7:0] out);
always @ (num)
begin
	case (num) 
		4'h0: begin out=`D0; end
		4'h1: begin out=`D1; end
		4'h2: begin out=`D2; end
		4'h3: begin out=`D3; end
		4'h4: begin out=`D4; end
		4'h5: begin out=`D5; end
		4'h6: begin out=`D6; end
		4'h7: begin out=`D7; end
		4'h8: begin out=`D8; end
		4'h9: begin out=`D9; end
		4'hA: begin out=`DA; end
		4'hB: begin out=`DB; end
		4'hC: begin out=`DC; end
		4'hD: begin out=`DD; end
		4'hE: begin out=`DE; end
		4'hF: begin out=`DF; end		
   default: begin out=`DX; end
	endcase
end
endmodule

module LED_MUX (
	input wire clk,
	input wire rst,
	input wire [7:0] LED0, // leftmost digit
	input wire [7:0] LED1,
	input wire [7:0] LED2,
	input wire [7:0] LED3,
	input wire [7:0] LED4,
	input wire [7:0] LED5,
	input wire [7:0] LED6,
	input wire [7:0] LED7, // rightmost digit
	output wire [7:0] LEDSEL,
	output wire [7:0] LEDOUT
	);
	
reg [2:0] index;
reg [15:0] led_ctrl;

assign {LEDOUT, LEDSEL} = led_ctrl;

always@(posedge clk)
begin
    index <= (rst) ? 3'd0 : (index + 3'd1);
end    

always @(index, LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7)
begin
	case(index)
	    3'd0: led_ctrl <= {8'b11111110, LED7}; 
	    3'd1: led_ctrl <= {8'b11111101, LED6};
	    3'd2: led_ctrl <= {8'b11111011, LED5};
	    3'd3: led_ctrl <= {8'b11110111, LED4};
	    3'd4: led_ctrl <= {8'b11101111, LED3};
	    3'd5: led_ctrl <= {8'b11011111, LED2};
	    3'd6: led_ctrl <= {8'b10111111, LED1};
	    3'd7: led_ctrl <= {8'b01111111, LED0};
     default: led_ctrl <= {8'b11111111, 8'hFF};
    endcase
end
endmodule


module timer #(parameter ticks = 500) (input clk, rst, we, [4:0] addr, [31:0] dataIn, output flag);
    
    reg [31:0] counter;
    reg [31:0] target;
    
    assign flag = (counter >= target) ? 1'b1 : 1'b0;
    
    always @ (posedge clk)
    begin
                
        if(rst == 1)
        begin
            counter = 0;
            target = ticks;
        end
        
        case (addr)
            5'b10110: 
                begin
                    if(we == 1)
                    begin
                        counter = dataIn;
                    end
                end
            
            5'b10111:
                begin
                    if(we == 1)
                    begin
                        target = dataIn;
                    end
                end
        
        endcase
                
        counter = counter + 1;
        
    end

endmodule


module debounce #(parameter width = 16) (
	output reg pb_debounced, 
	input wire pb, 
	input wire clk
	);

localparam shift_max = (2**width)-1;

reg [width-1:0] shift;

always @ (posedge clk)
begin
	shift[width-2:0] <= shift[width-1:1];
	shift[width-1] <= pb;
	if (shift == shift_max)
		pb_debounced <= 1'b1;
	else
		pb_debounced <= 1'b0;
end
endmodule


//MODULES FOR HARDWARE
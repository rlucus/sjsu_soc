module mux2 #(parameter wide = 8)
(input sel, [wide-1:0] a, b, output [wide-1:0] y);
    assign y = sel ? b : a;
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
(input [3:0] op, [wide-1:0] a, b, [4:0] shiftamount, output zero, reg [wide-1:0] y);
    assign zero = (y == 'h0);
    always @ (op, a, b)
        case (op)
            4'b0000: y = a & b;
            4'b0001: y = a | b;
            4'b0010: y = a + b;
            4'b0011: y = ~(a | b);//NOR
            4'b0100: y = b << shiftamount;//SLL
            4'b0101: y = b >> shiftamount;//SRL
            4'b0110: y = a - b;
            4'b0111: y = (a < b) ? 1 : 0;
            4'b1000: y = b >>> shiftamount;//SRA
            4'b1001: y = a ^ b;//XOR
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
(input [5:0] a, output [wide-1:0] y);
    reg [wide-1:0] rom [0:63];
    initial $readmemh ("memfile.dat", rom);
    assign y = rom[a];
endmodule

module dmem #(parameter wide = 8)
(input clk, we, [5:0] a, [wide-1:0] d, output [wide-1:0] q);
    reg [wide-1:0] ram [0:63];
    always @ (posedge clk) if (we) ram[a] <= d;
    assign q = ram[a];
endmodule

module maindec
(input [5:0] op, output reg branch, jump, link, reg_dst, we_reg, alu_src, we_dm, dm2reg, reg [1:0] alu_op);
    reg [9:0] ctrl;
    always @ (ctrl) {branch, jump, link, reg_dst, we_reg, alu_src, we_dm, dm2reg, alu_op} = ctrl;
    always @ (op)
        case (op)
            6'b000000: ctrl = 10'b0_0_0_1_1_0_0_0_10; // R-Type
            6'b100011: ctrl = 10'b0_0_0_0_1_1_0_1_00; // LW
            6'b101011: ctrl = 10'b0_0_0_0_0_1_1_0_00; // SW
            6'b000100: ctrl = 10'b1_0_0_0_0_0_0_0_01; // BEQ
            6'b001000: ctrl = 10'b0_0_0_0_1_1_0_0_00; // ADDI
            6'b000010: ctrl = 10'b0_1_0_0_0_0_0_0_00; // J
            6'b000011: ctrl = 10'b0_1_1_0_1_0_0_0_00; // JAL
            default: ctrl = 10'bx;
        endcase
endmodule

module auxdec
(input [1:0] alu_op, [5:0] funct, output reg jump_reg, we_hi, we_lo, hi2reg, lo2reg, reg [3:0] alu_ctrl);
    reg [8:0] ctrl;
    //adjusting alucontrol
    always @ (ctrl) {jump_reg, we_hi, we_lo, hi2reg, lo2reg, alu_ctrl} = ctrl;
    always @ (alu_op, funct)
        case (alu_op)
            2'b00: ctrl = 8'b0_0_0_0_0_010; // add
            2'b01: ctrl = 8'b0_0_0_0_0_110; // sub
            default: case (funct)
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
                default: ctrl = 8'bx;
            endcase
        endcase
endmodule
/*
module coprocessor0 (input clk, rst, enable, [4:0] ctrl, [31:0] coprocessorIn1, [31:0] coprocessorIn2 , output reg [31:0] coprocessorOut);
    
        //register 12
        //register 13
        //register 14
        dreg #(32) EPC(.clk(clk), .rst(rst), .en(en), .d(), .q());
    
    
    always @(coprocessorIn)
        //coprocessorOut = coprocessorIn;
    
        case(ctrl)
        
        5'b:00100
    


endmodule
*/
module mips
(input         clk, rst,
 input  [31:0] instr, rd_dm,
 output        we_dm,
 output [31:0] pc_current, alu_out, wd_dm);    
    wire       pc_src, jump, link, jump_reg ,reg_dst, we_reg, alu_src, we_hi, we_lo, hi2reg, lo2reg, zero, dm2reg;
    wire [2:0] alu_ctrl;
    datapath    DP (clk, rst, pc_src, jump, link, jump_reg ,reg_dst, we_reg, alu_src, we_hi, we_lo, hi2reg, lo2reg, dm2reg, alu_ctrl, instr[25:0], rd_dm, zero, pc_current, alu_out, wd_dm);
    controlunit CU (zero, instr[31:26], instr[5:0], pc_src, jump, link, jump_reg ,reg_dst, we_reg, alu_src, we_hi, we_lo, hi2reg, lo2reg, we_dm, dm2reg, alu_ctrl);
endmodule

module datapath
(input         clk, rst, pc_src, jump, link, jump_reg, reg_dst, we_reg, alu_src, we_hi, we_lo, hi2reg, lo2reg, dm2reg,
 input  [2:0]  alu_ctrl,
 input  [25:0] instr, 
 input  [31:0] rd_dm,
 output        zero,
 output [31:0] pc_current, alu_out, wd_dm);
    wire [4:0]  wa_rf, jal_rf;
    wire [31:0] pc_pre, pc_next, pc_plus4, jra, jta, sext_imm, ba, bta, alu_pa, alu_pb, hi_dat, lo_dat, hi_res, lo_res, wd_rf, wd_rf_res;
    wire [63:0] product;
    assign jta = {pc_plus4[31:28], instr[25:0], 2'b00};
    assign ba  = {sext_imm[29:0], 2'b00};
    // Next PC Logic
    mux2    #(32) pc_jr_mux  (jump_reg, pc_plus4, alu_pa, jra);
    mux2    #(32) pc_src_mux (pc_src, jra, bta, pc_pre);
    mux2    #(32) pc_jmp_mux (jump, pc_pre, jta, pc_next);
    dreg    #(32) pc_reg     (clk, rst, 1, pc_next, pc_current);
    adder   #(32) pc_add4    (pc_current, 4, pc_plus4);
    adder   #(32) pc_add_bra (pc_plus4, ba, bta);
    signext       se         (instr[15:0], sext_imm);
    // RF Logic
    mux2    #(5)  rf_wa_mux  (reg_dst, instr[20:16], instr[15:11], wa_rf);
    mux2    #(5)  rf_jal_mux (link, wa_rf, 31, jal_rf);
    mux2    #(32) rf_wd_mux  (link, lo_res, pc_plus4, wd_rf_res);
    regfile #(32) rf         (clk, we_reg, jal_rf, instr[25:21], instr[20:16], wd_rf_res, alu_pa, wd_dm);
    // ALU Logic
    mux2    #(32) alu_pb_mux (alu_src, wd_dm, sext_imm, alu_pb);
    alu     #(32) alu        (alu_ctrl, alu_pa, alu_pb, zero, alu_out);
    multi   #(32) multi      (alu_pa, alu_pb, product[63:32], product[31:0]);
    dreg    #(32) high       (clk, rst, we_hi, product[63:32], hi_dat);
    dreg    #(32) low        (clk, rst, we_lo, product[31:0], lo_dat);
    mux2    #(32) wd_rf_mux  (dm2reg, alu_out, rd_dm, wd_rf);
    mux2    #(32) hi_mux     (hi2reg, wd_rf, hi_dat, hi_res);
    mux2    #(32) lo_mux     (lo2reg, hi_res, lo_dat, lo_res);
endmodule

module controlunit
(input        zero,
 input  [5:0] op, funct,
 output       pc_src, jump, link, jump_reg, reg_dst, we_reg, alu_src, we_hi, we_lo, hi2reg, lo2reg, we_dm, dm2reg,
 output [2:0] alu_ctrl);
    wire       branch;
    wire [1:0] alu_op;
    assign pc_src = branch & zero;
    maindec MD (op, branch, jump, link, reg_dst, we_reg, alu_src, we_dm, dm2reg, alu_op);
    auxdec  AD (alu_op, funct, jump_reg ,we_hi, we_lo, hi2reg, lo2reg, alu_ctrl);
endmodule
module mips
(input         clk, rst,
 input  [31:0] instr, rd_dm,
 output        we_dm,
 output [31:0] pc_current, alu_out, wd_dm);    
    wire       pc_src, jump, link, jump_reg ,reg_dst, we_reg, alu_src, we_hi, we_lo, hi2reg, lo2reg, zero, dm2reg;
    wire [2:0] alu_ctrl;
    datapath    DP (.clk(clk), .rst(rst), .pc_src(pc_src), .jump(jump), .link(link), .jump_reg(jump_reg) ,.reg_dst(reg_dst), .we_reg(we_reg), 
        .alu_src(alu_src), .we_hi(we_hi), .we_lo(we_lo), .hi2reg(hi2reg), .lo2reg(lo2reg), .dm2reg(dm2reg), .alu_ctrl(alu_ctrl), 
        .instr(instr[25:0]), .rd_dm(rd_dm), .zero(zero), .pc_current(pc_current), .alu_out(alu_out), .wd_dm(wd_dm));
    
    controlunit CU (.zero(zero), .op(instr[31:26]), .funct(instr[5:0]), .pc_src(pc_src), .jump(jump), 
        .link(link), .jump_reg(jump_reg) ,.reg_dst(reg_dst), .we_reg(we_reg), .alu_src(alu_src), .we_hi(we_hi), .we_lo(we_lo), 
        .hi2reg(hi2reg), .lo2reg(lo2reg), .we_dm(we_dm), .dm2reg(dm2reg), .alu_ctrl(alu_ctrl));
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
    mux2    #(32) pc_jr_mux  (.sel(jump_reg), .a(pc_plus4), .b(alu_pa), .y(jra));
    mux2    #(32) pc_src_mux (.sel(pc_src), .a(jra), .b(bta), .y(pc_pre));
    mux2    #(32) pc_jmp_mux (.sel(jump), .a(pc_pre), .b(jta), .y(pc_next));
    dreg    #(32) pc_reg     (.clk(clk), .rst(rst), .en(1), .d(pc_next), .q(pc_current));
    adder   #(32) pc_add4    (.a(pc_current), .b(4), .y(pc_plus4));
    adder   #(32) pc_add_bra (.a(pc_plus4), .b(ba), .y(bta));
    signext       se         (.a(instr[15:0]), .y(sext_imm));
    // RF Logic
    mux2    #(5)  rf_wa_mux  (.sel(reg_dst), .a(instr[20:16]), .b(instr[15:11]), .y(wa_rf));
    mux2    #(5)  rf_jal_mux (.sel(link), .a(wa_rf), .b(31), .y(jal_rf));
    mux2    #(32) rf_wd_mux  (.sel(link), .a(lo_res), .b(pc_plus4), .y(wd_rf_res));
    regfile #(32) rf         (.clk(clk), .we(we_reg), .wa(jal_rf), .ra1(instr[25:21]), .ra2(instr[20:16]), .wd(wd_rf_res), .rd1(alu_pa), .rd2(wd_dm));
    // ALU Logic
    mux2    #(32) alu_pb_mux (.sel(alu_src), .a(wd_dm), .b(sext_imm), .y(alu_pb));
    alu     #(32) alu        (.op(alu_ctrl), .a(alu_pa), .b(alu_pb), .zero(zero), .y(alu_out));
    multi   #(32) multi      (.a(alu_pa), .b(alu_pb), .h(product[63:32]), .l(product[31:0]));
    dreg    #(32) high       (.clk(clk), .rst(rst), .en(we_hi), .d(product[63:32]), .q(hi_dat));
    dreg    #(32) low        (.clk(clk), .rst(rst), .en(we_lo), .d(product[31:0]), .q(lo_dat));
    mux2    #(32) wd_rf_mux  (.sel(dm2reg), .a(alu_out), .b(rd_dm), .y(wd_rf));
    mux2    #(32) hi_mux     (.sel(hi2reg), .a(wd_rf), .b(hi_dat), .y(hi_res));
    mux2    #(32) lo_mux     (.sel(lo2reg), .a(hi_res), .b(lo_dat), .y(lo_res));
endmodule

module controlunit
(input        zero,
 input  [5:0] op, funct,
 output       pc_src, jump, link, jump_reg, reg_dst, we_reg, alu_src, we_hi, we_lo, hi2reg, lo2reg, we_dm, dm2reg,
 output [2:0] alu_ctrl);
    wire       branch;
    wire [1:0] alu_op;
    assign pc_src = branch & zero;
    maindec MD (.op(op), .branch(branch), .jump(jump), .link(link), .reg_dst(reg_dst), .we_reg(we_reg), .alu_src(alu_src), .we_dm(we_dm), .dm2reg(dm2reg), .alu_op(alu_op));
    auxdec  AD (.alu_op(alu_op), .funct(funct), .jump_reg(jump_reg), .we_hi(we_hi), .we_lo(we_lo), .hi2reg(hi2reg), .lo2reg(lo2reg), .alu_ctrl(alu_ctrl));
endmodule
module mips_top
(input clk, rst, [3:0] INT, output [31:0] pc_current, instr, dmem_addr, dmem_out, rd_dm);
    //wire [31:0] instr, alu_out, wd_dm, rd_dm;
    wire dmem_we;
    //mips      MIPS (.clk(clk), .rst(rst), .instr(instr), .rd_dm(rd_dm), .we_dm(we_dm), .pc_current(pc_current), .alu_out(alu_out), .wd_dm(wd_dm), .INT(INT));
    mips      MIPS (.clk(clk), .rst(rst), .instr(instr), .rd_dm(rd_dm), .dmem_we(dmem_we), .pc_current(pc_current), .dmem_addr(dmem_addr), .dmem_out(dmem_out), .INT(INT));
    //imem #(32)IMEM (.a(pc_current[7:2]), .y(instr));
    imem #(32)IMEM (.a(pc_current), .y(instr));
    //dmem #(32)DMEM (.clk(clk), .we(we_dm), .a(alu_out), .d(wd_dm), .q(rd_dm));
    dmem #(32)DMEM (.clk(clk), .we(dmem_we), .a(dmem_addr), .d(dmem_out), .q(rd_dm));
   
    //mips      MIPS (.clk(clk_5KHz), .rst(rst), .instr(instr), .rd_dm(rd_dm), .we_dm(we_dm), .pc_current(pc_current), .alu_out(alu_out), .wd_dm(wd_dm));
    //dmem #(32)DMEM (.clk(clk_5KHz), .we(we_dm), .a(alu_out[5:0]), .d(wd_dm), .q(rd_dm));
    
    
    
    
endmodule


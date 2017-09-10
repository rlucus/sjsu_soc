module mips_top
(input clk, rst, output [31:0] pc_current, instr, alu_out, wd_dm, rd_dm);
    wire we_dm;
    mips      MIPS (clk, rst, instr, rd_dm, we_dm, pc_current, alu_out, wd_dm);
    imem #(32)IMEM (pc_current[7:2], instr);
    dmem #(32)DMEM (clk, we_dm, alu_out[5:0], wd_dm, rd_dm);
endmodule
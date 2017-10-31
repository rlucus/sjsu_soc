module mips_top
(input clk, rst, [4:0] INT, output [31:0] pc_current, instr, alu_out, wd_dm, rd_dm);
    //wire [31:0] instr, alu_out, wd_dm, rd_dm;
    wire we_dm;
    mips      MIPS (.clk(clk), .rst(rst), .instr(instr), .rd_dm(rd_dm), .we_dm(we_dm), .pc_current(pc_current), .alu_out(alu_out), .wd_dm(wd_dm), .INT(INT));
    imem #(32)IMEM (.a(pc_current[7:2]), .y(instr));
    dmem #(32)DMEM (.clk(clk), .we(we_dm), .a(alu_out[5:0]), .d(wd_dm), .q(rd_dm));
   
   //test code
   wire clksec, clk_5KHz;
    
        clk_gen top_clk(
        .clk100MHz(clk),
        .rst(rst),
        .clk_sec(clksec),
        .clk_5KHz(clk_5KHz)
        );
    //mips      MIPS (.clk(clk_5KHz), .rst(rst), .instr(instr), .rd_dm(rd_dm), .we_dm(we_dm), .pc_current(pc_current), .alu_out(alu_out), .wd_dm(wd_dm));
    //dmem #(32)DMEM (.clk(clk_5KHz), .we(we_dm), .a(alu_out[5:0]), .d(wd_dm), .q(rd_dm));
    
    
endmodule


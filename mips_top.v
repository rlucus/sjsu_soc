module mips_top
(input clk, rst, output [31:0] pc_current, instr, alu_out, wd_dm, rd_dm);
    wire we_dm;
    mips      MIPS (clk, rst, instr, rd_dm, we_dm, pc_current, alu_out, wd_dm);
    imem #(32)IMEM (pc_current[7:2], instr);
    dmem #(32)DMEM (clk, we_dm, alu_out[5:0], wd_dm, rd_dm);
    
    
    CPzero dut1(
        .clk (0), 
        .rst (0), 
        .we1 (0), 
    	.alu_trap(0), 
    	.addr(0), 
    	.interrupt(0), 
    	.wd  (0), 
    	.pcp4(0), 
        .exl (), 
        .iv  (), 
     	.rd1 ()
     	);
    
    aes_block dut2(
        // Clock and reset.
        .clk    (0),
        .reset_n(0),
       
        // Control.
        .cs(0),
        .we(0),

        // Data ports.
        .address   (0),
        .INT       (),

        .write_block(),
        .read_block ()
        );
    
endmodule
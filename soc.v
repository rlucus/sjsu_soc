module soc (input clk450MHz, rst, [3:0] INT , output pc_current);

    wire clk_sec;
    wire [30:0] test;
    
    clk_gen sysClock (.clk450MHz(clk450MHz), .rst(rst), .clk_sec(clk_sec));
    
    mips_top core (.clk(clk_sec), .rst(rst), .INT(INT), .pc_current({test, pc_current}));
 /*mips_top
(input clk, rst, [4:0] INT, output [31:0] pc_current, instr, alu_out, wd_dm, rd_dm);*/


endmodule
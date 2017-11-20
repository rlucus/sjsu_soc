module soc (input clk450MHz, rst, [3:0] INT , output uart_rx_out,output pc_current);

    wire clk_sec, clk_10MHz;
    wire [30:0] test;
    
    clk_gen sysClock (.clk450MHz(clk450MHz), .rst(rst), .clk_5KHz(clk_sec), .clk_1MHz(clk_1MHz));
    
    mips_top core (.clk(clk_1MHz), .serialClk(clk_1MHz), .rst(rst), .INT(INT), .pc_current({test, pc_current}), .serial(uart_rx_out));
    
 /*mips_top
(input clk, rst, [4:0] INT, output [31:0] pc_current, instr, alu_out, wd_dm, rd_dm);*/


endmodule
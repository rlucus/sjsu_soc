


module soc (input clk450MHz, rst, [3:0] INT , output uart_rx_out, output oled_sdin, oled_sclk, oled_dc, oled_res, oled_vbat, oled_vdd, output [7:0] led, input btnr, btnl, sw6, sw7);

    wire clk_sec, clk_10MHz;
    
    clk_gen sysClock (.clk450MHz(clk450MHz), .rst(btnl), .clk_5KHz(clk_sec), .clk_1MHz(clk_1MHz), .btnr(btnr), .sw7(sw7), .sw6(sw6), .clk_special(clk_special));
    
    wire [31:0] pc_current, instr;
    mips_top core (.clk(clk_1MHz), .serialClk(clk_1MHz), .rst(btnl), .INT(INT), .pc_current(pc_current), .instr(instr), .serial(uart_rx_out));
    
	wire [7:0] led;
    spiScreen screen( .clk(clk450MHz), .rstn(rst), .pc(pc_current), .instr(instr), .oled_sdin(oled_sdin), .oled_sclk(oled_sclk), .oled_dc(oled_dc), .oled_res(oled_res), .oled_vbat(oled_vbat), .oled_vdd(oled_vdd), .led(led) );


 /*mips_top
(input clk, rst, [4:0] INT, output [31:0] pc_current, instr, alu_out, wd_dm, rd_dm);*/


endmodule



module soc (input        sysclk_n, sysclk_p, 
						 rst, 
//				   [3:0] INT , 
			output       uart_rx_out, 
			output       oled_sdin, 
			             oled_sclk, 
			             oled_dc, 
			             oled_res, 
			             oled_vbat, 
			             oled_vdd, 
			output [7:0] led, 
			input        btnl, 
			       [7:0] switch
	);

	wire clk450MHz;
    // IBUFDS: Differential Input Buffer
    // 7 Series
    // Xilinx HDL Libraries Guide, version 14.6
    IBUFDS #(
        .DIFF_TERM("FALSE"), // Differential Termination
        .IBUF_LOW_PWR("TRUE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("DEFAULT") // Specify the input I/O standard
        ) IBUFDS_inst (
            .O(clk450MHz), // Buffer output
            .I(sysclk_p), // Diff_p buffer input (connect directly to top-level port)
            .IB(sysclk_n) // Diff_n buffer input (connect directly to top-level port)
    );
    // End of IBUFDS_inst instantiation   );

    wire clk_sec, clk_10MHz;
    
    clk_gen sysClock (.clk450MHz(clk450MHz), .rst(btnl), .clk_sec(clk_sec), .clk_5KHz(clk_5KHz), .clk_1MHz(clk_1MHz) );
    
    wire [31:0] pc_current, instr;
    mips_top core (.clk(clk_special), .serialClk(clk_1MHz), .rst(btnl), .INT(switch[3:0]), .pc_current(pc_current), .instr(instr), .serial(uart_rx_out) );
    
	wire [7:0] led;
    spiScreen screen( .clk(clk450MHz), .rstn(rst), .pc(pc_current), .instr(instr), .oled_sdin(oled_sdin), .oled_sclk(oled_sclk), .oled_dc(oled_dc), .oled_res(oled_res), .oled_vbat(oled_vbat), .oled_vdd(oled_vdd), .led(led) );

    wire clk_special;
    assign clk_special = switch[7] ? clk_1MHz : (switch[6] ? clk_5KHz : (switch[5] ? clk_sec : 0) );


 /*mips_top
(input clk, rst, [4:0] INT, output [31:0] pc_current, instr, alu_out, wd_dm, rd_dm);*/


endmodule
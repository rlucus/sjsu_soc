`timescale 1ns / 1ps
/*******************************************
 * Group: Accelerated SoC
 * Engineer: Kai M Wetlesen
 * 
 * Create Date: 04/24/2017 04:00:09 PM
 * Design Name: Rijndael Key Scheduler
 * Project Name: AES 256 Core IP
 * Target Devices: Artix-7 CSG324
 * Tool Versions: Vivado 2016.2
 * Description: Describes the core hardware
 *              which drives the Rijndael key
 *              mixing unit.
 * 
 * Dependencies: None
 * 
 * Revision History:
 * Revision 0.01 - File Created
 * 
 * Additional Comments:
 * 
 *******************************************/

 /**********************************
  * Module Name: rotate_wl
  * Description: Rotates input word
  *     left bitwise by 1 bit.
  **********************************/
module g_add(input [7:0] sel, output [7:0] result);
    
endmodule

/**********************************
 * Module Name: rotate_wl
 * Description: Rotates input word
 *     left bitwise by 1 bit.
 **********************************/
module rotate_wl #(parameter n_bits = 8)(
    input [31:0] data,
    output [31:0] result
    );
    assign result[31:n_bits] = data[31-n_bits:0];
    assign result[n_bits-1:0] = data[31:n_bits];
endmodule

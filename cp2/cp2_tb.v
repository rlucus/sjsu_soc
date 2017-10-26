`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2017 06:54:02 AM
// Design Name: 
// Module Name: cp2_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cp2_tb();

    reg [255:0] KEY = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    reg [127:0] DATA = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    //Encrypted DATA
    reg [127:0] EDATA = 128'hD5F93D6D3311CB309F23621B02FBD5E2;
    reg [127:0] BUFFER = 128'h00000000000000000000000000000000;

    reg clk = 1'b0;
    reg reset = 1'b0;
    reg write_en = 1'b0;
    
    reg encdec = 0;
    reg size = 0;
    reg cs = 0;
    wire INT;
    
    
    reg [4:0] addr = 5'b0;
    reg [31:0] write_data = 32'b0;
    wire [31:0] read_data;
    

    aes_wrapper u1 (.clock(clk), .reset(reset), .write_en(write_en), .address(addr), .write_data(write_data), .read_data(read_data), .cs(cs), .INT(INT));
    
    /*            parameter ADDR_CTRL        = 8'h08;
                  parameter CTRL_INIT_BIT    = 0;
                  parameter CTRL_NEXT_BIT    = 1;
                  parameter CTRL_ENCDEC_BIT  = 2;
                  parameter CTRL_KEYLEN_BIT  = 3;
  
                  parameter ADDR_STATUS      = 8'h09;
                  parameter STATUS_READY_BIT = 0;
                  parameter STATUS_VALID_BIT = 1;
    
                parameter AES_128_BIT_KEY = 0;
                parameter AES_256_BIT_KEY = 1;
    
                parameter AES_DECIPHER = 1'b0;
                parameter AES_ENCIPHER = 1'b1;

    
                BOOK KEEPING, what the module is
                5'd00: addr_out = ADDR_NAME0;
                Some other name provided
                5'd01: addr_out = ADDR_NAME1;
                Verion of the design, hardware revision
                5'd02: addr_out = ADDR_VERSION;
                
                ADDR_CTRL = 28'h0, keylen_reg, encdec_reg, next_reg, init_reg
                5'd03: addr_out = ADDR_CTRL;
                
                ADDR_STATUS = 30'h0, valid_reg, ready_reg
                5'd04: addr_out = ADDR_STATUS;
                
                //ADDR_CONFIG = config_we = 1'b1;
                5'd05: addr_out = ADDR_CONFIG;
                
                USED FOR KEY LOADING
                5'd06: addr_out = ADDR_KEY0;
                5'd07: addr_out = ADDR_KEY1;
                5'd08: addr_out = ADDR_KEY2;
                5'd09: addr_out = ADDR_KEY3;
                5'h0A: addr_out = ADDR_KEY4;
                5'h0B: addr_out = ADDR_KEY5;
                5'h0C: addr_out = ADDR_KEY6;
                5'h0D: addr_out = ADDR_KEY7;
                USED TO INPUT A DATA BLOCK
                5'h0E: addr_out = ADDR_BLOCK0;
                5'h0F: addr_out = ADDR_BLOCK1;
                5'h10: addr_out = ADDR_BLOCK2;
                5'h11: addr_out = ADDR_BLOCK3;
                USED TO READ DATA OUT
                5'h12: addr_out = ADDR_RESULT0;
                5'h13: addr_out = ADDR_RESULT1;
                5'h14: addr_out = ADDR_RESULT2;
                5'h15: addr_out = ADDR_RESULT3;*/
                
    initial begin
                //reset logic
                reset = 1;
                bounce();
                bounce();
                reset = 0;
                bounce;
                
                
                //read module info
                addr = 5'b0;
                bounce();
                addr = 5'b00001;
                bounce();
                addr = 5'b00010;
                bounce();
                
                //ctrl logic
                //keylen_reg, encdec_reg, next_reg, init_reg
                //addr = 5'h08;
                //write_data = 32'h0000_000C;
                //write_data = 32'h0000_000F; 
                //write_en = 1;
                //bounce();
                
                
                //load key
                 //load key
                 //6
                 addr = 5'h06;
                 write_data = KEY[31:0];
                 write_en = 1;
                 cs = 1;
                 bounce();
                 //7
                 addr = 5'h07;
                 write_data = KEY[63:32];
                 write_en = 1;
                 cs = 1;
                 bounce();
                 //8
                 addr = 5'h08;
                 write_data = KEY[95:64];
                 write_en = 1;
                 cs = 1;
                 bounce();
                 //9
                 addr = 5'h09;
                 write_data = KEY[127:96];
                 write_en = 1;
                 cs = 1;
                 bounce();
                 //A
                 addr = 5'h0A;
                 write_data = KEY[159:128];
                 write_en = 1;
                 cs = 1;
                 bounce();
                 //B
                 addr = 5'h0B;
                 write_data = KEY[191:160];
                 write_en = 1;
                 cs = 1;
                 bounce();
                 //C
                 addr = 5'h0C;
                 write_data = KEY[223:192];
                 write_en = 1;
                 cs = 1;
                 bounce();
                 //D
                 addr = 5'h0D;
                 write_data = KEY[255:224];
                 write_en = 1;
                 cs = 1;
                 bounce();
                 
                 //addr config
                 addr = 5'h05;
                 write_data = 32'h0000_00002;
                 write_en = 1;
                 cs = 1;
                 bounce();
                 
                 addr = 5'h03;
                 write_data = 32'h0000_0001;
                 write_en = 1;
                 cs = 1;
                 bounce();
                 
                 write_en = 0;
                 cs = 0;
                 bounce();
                 //clocks
                 repeat(15)
                 begin
                 bounce();
                 end
                 
                 
                 //load data
                 //E
                  addr = 5'h0E;
                  write_data = DATA[31:0];
                  write_en = 1;
                  cs = 1;
                  bounce();
                  //F
                  addr = 5'h0F;
                  write_data = DATA[63:32];
                  write_en = 1;
                  cs = 1;
                  bounce();
                  //10
                  addr = 5'h10;
                  write_data = DATA[95:64];
                  write_en = 1;
                  cs = 1;
                  bounce();
                  //11
                  addr = 5'h11;
                  write_data = DATA[127:96];
                  write_en = 1;
                  cs = 1;
                  bounce();                 
                
                
                 //ctrl logic
                 //keylen_reg, encdec_reg, next_reg, init_reg
                 //addr = 5'h08;
                 //write_data = 32'h0000_000D;
                 //write_data = 32'h0000_000F; 
                 //write_en = 1;
                 //bounce();
                
                
                 //addr config
                 addr = 5'h05;
                 write_data = 32'h0000_00003;
                 write_en = 1;
                 cs = 1;
                 bounce();
                 
                 addr = 5'h03;
                 write_data = 32'h0000_0002;
                 write_en = 1;
                 cs = 1;
                 bounce();
                
                write_en = 0;
                cs = 0;
                 
                 
                 
                 while(!INT)
                 begin
                    bounce();
                 end
                
                repeat(100)
                begin
                bounce();
                end
                
                //load data
 
                addr = 5'h12;
                cs = 1;
                #5;
                BUFFER[127:96] = read_data;
                bounce();
                //BUFFER[127:96] = read_data;
                addr = 5'h13;
                
                BUFFER[95:64] = read_data;
                bounce();
                
                addr = 5'h14;
                BUFFER[63:32] = read_data;
                bounce();
                
                addr = 5'h15;
                BUFFER[31:0] = read_data;
                cs = 0;
                bounce();
                
                
                
                //END OF ENCRYPTION TEST
                
                //START OF DECRYPTION TEST
                
                
                
                //load key
                                 //6
                                 addr = 5'h06;
                                 write_data = KEY[31:0];
                                 write_en = 1;
                                 cs = 1;
                                 bounce();
                                 //7
                                 addr = 5'h07;
                                 write_data = KEY[63:32];
                                 write_en = 1;
                                 cs = 1;
                                 bounce();
                                 //8
                                 addr = 5'h08;
                                 write_data = KEY[95:64];
                                 write_en = 1;
                                 cs = 1;
                                 bounce();
                                 //9
                                 addr = 5'h09;
                                 write_data = KEY[127:96];
                                 write_en = 1;
                                 cs = 1;
                                 bounce();
                                 //A
                                 addr = 5'h0A;
                                 write_data = KEY[159:128];
                                 write_en = 1;
                                 cs = 1;
                                 bounce();
                                 //B
                                 addr = 5'h0B;
                                 write_data = KEY[191:160];
                                 write_en = 1;
                                 cs = 1;
                                 bounce();
                                 //C
                                 addr = 5'h0C;
                                 write_data = KEY[223:192];
                                 write_en = 1;
                                 cs = 1;
                                 bounce();
                                 //D
                                 addr = 5'h0D;
                                 write_data = KEY[255:224];
                                 write_en = 1;
                                 cs = 1;
                                 bounce();
                                 
                                 //addr config
                                 addr = 5'h05;
                                 write_data = 32'h0000_00002;
                                 write_en = 1;
                                 cs = 1;
                                 bounce();
                                 
                                 addr = 5'h03;
                                 write_data = 32'h0000_0001;
                                 write_en = 1;
                                 cs = 1;
                                 bounce();
                                 
                                 write_en = 0;
                                 cs = 0;
                                 bounce();
                                 //clocks
                                 repeat(15)
                                 begin
                                 bounce();
                                 end
                
                
                
                
                
                
                
                
                
                //load data
                                 //E
                                  addr = 5'h0E;
                                  write_data = BUFFER[31:0];
                                  write_en = 1;
                                  cs = 1;
                                  bounce();
                                  //F
                                  addr = 5'h0F;
                                  write_data = BUFFER[63:32];
                                  write_en = 1;
                                  cs = 1;
                                  bounce();
                                  //10
                                  addr = 5'h10;
                                  write_data = BUFFER[95:64];
                                  write_en = 1;
                                  cs = 1;
                                  bounce();
                                  //11
                                  addr = 5'h11;
                                  write_data = BUFFER[127:96];
                                  write_en = 1;
                                  cs = 1;
                                  bounce();                 
                                
                                
                                 //ctrl logic
                                 //keylen_reg, encdec_reg, next_reg, init_reg
                                 //addr = 5'h08;
                                 //write_data = 32'h0000_000D;
                                 //write_data = 32'h0000_000F; 
                                 //write_en = 1;
                                 //bounce();
                                
                                
                                 //addr config
                                 addr = 5'h05;
                                 write_data = 32'h0000_00002;
                                 write_en = 1;
                                 cs = 1;
                                 bounce();
                                 
                                 addr = 5'h03;
                                 write_data = 32'h0000_0002;
                                 write_en = 1;
                                 cs = 1;
                                 bounce();
                                
                                write_en = 0;
                                cs = 0;
                                 
                                 
                                 
                                 while(!INT)
                                 begin
                                    bounce();
                                 end
                                
                                repeat(100)
                                begin
                                bounce();
                                end
                                
                                
                                cs = 1;
                                addr = 5'h12;
                                BUFFER[31:0] = read_data;
                                bounce();
                                addr = 5'h13;
                                BUFFER[63:32] = read_data;
                                bounce();
                                addr = 5'h14;
                                BUFFER[95:64] = read_data;
                                bounce();
                                addr = 5'h15;
                                BUFFER[127:96] = read_data;
                                bounce();
                                cs = 0;
                
                
                
                
                
                
                
                
                
                
                //END OF DECRYPTION TEST
                
    end            
      
    //move clock forward
    task bounce;
        begin
            #5;
            clk = 1;
            #5;
            clk = 0;
            #5;
            
        end
    endtask    

    
endmodule

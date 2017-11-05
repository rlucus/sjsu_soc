`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This is a testbench for the AES module being used. 
// The first round takes a key and data of all F's
//      -Data is encryped and tested against expected results
//      -Encrypted data is then decrypted and tested against original input
// The second rounnd only tests final result after feeding encrypted data back in
//      -Generate random 256-key
//      -Data block repeating incrimental hex 0->F
//      -Encrypt -> Decrypt -> verify integrity of data
// The third test uses the 128-bit encryption option
//      -Generate random key
//      -Encrypt -> Decrypt -> verify integrity of data      
//////////////////////////////////////////////////////////////////////////////////


module tb_aes();

    reg [255:0] KEY    = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF_FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    reg [127:0] DATA1  = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    reg [127:0] DATA2  = 128'h0123_4567_89ab_cdef_0123_4567_89ab_cdef;
    //Encrypted DATA
    reg [127:0] EDATA  = 128'hD5F93D6D3311CB309F23621B02FBD5E2;
    reg [127:0] BUFFER = 128'h00000000000000000000000000000000;

    reg clk      = 1'b0;
    reg rst      = 1'b0;
    reg write_en = 1'b0;
    
    reg  encdec  = 0; // dec(0)/enc(1)
    reg  encType = 0; // 128(0)/256(1)
    reg  cs      = 0;
    reg  keyLen  = 0;
    wire INT;
    
    reg  [ 7:0] addr       =  8'b0;
    reg  [31:0] write_data = 32'b0;
    wire [31:0] read_data;
 
    reg DEBUG = 0;   

      // The DUT address map.
      parameter ADDR_NAME0       = 8'h00;
      parameter ADDR_NAME1       = 8'h01;
      parameter ADDR_VERSION     = 8'h02;
    
      parameter ADDR_CTRL        = 8'h08;
      parameter CTRL_INIT_BIT    = 0;
      parameter CTRL_NEXT_BIT    = 1;
      parameter CTRL_ENCDEC_BIT  = 2;
      parameter CTRL_KEYLEN_BIT  = 3;
    
      parameter ADDR_STATUS      = 8'h09;
      parameter STATUS_READY_BIT = 0;
      parameter STATUS_VALID_BIT = 1;
    
      parameter ADDR_CONFIG      = 8'h0a;
    
      parameter ADDR_KEY0        = 8'h10;
      parameter ADDR_KEY1        = 8'h11;
      parameter ADDR_KEY2        = 8'h12;
      parameter ADDR_KEY3        = 8'h13;
      parameter ADDR_KEY4        = 8'h14;
      parameter ADDR_KEY5        = 8'h15;
      parameter ADDR_KEY6        = 8'h16;
      parameter ADDR_KEY7        = 8'h17;
    
      parameter ADDR_BLOCK0      = 8'h20;
      parameter ADDR_BLOCK1      = 8'h21;
      parameter ADDR_BLOCK2      = 8'h22;
      parameter ADDR_BLOCK3      = 8'h23;
    
      parameter ADDR_RESULT0     = 8'h30;
      parameter ADDR_RESULT1     = 8'h31;
      parameter ADDR_RESULT2     = 8'h32;
      parameter ADDR_RESULT3     = 8'h33;
    
      parameter AES_128_BIT_KEY = 0;
      parameter AES_256_BIT_KEY = 1;
    
      parameter AES_DECIPHER = 1'b0;
      parameter AES_ENCIPHER = 1'b1; 
      
 /*   aes_wrapper u1 (.clock(clk), 
                    .reset(rst), 
                    .write_en(write_en), 
                    .address(addr), 
                    .write_data(write_data), 
                    .read_data(read_data), 
                    .cs(cs), 
                    .INT(INT)
                    );
 */   

    aes u1(
           // Clock and reset.
           .clk(clk),
           .reset_n(rst),

           // Control.
           .cs(cs),
           .we(write_en),

           // Data ports.
           .address(addr),
           .write_data(write_data),
           .INT(INT),
           .read_data(read_data)
           );

integer counter = 0;
    //move clock forward
    task tickTock;  begin
        #5;
        clk = 1;
        #5;
        clk = 0;
        counter = counter+1;
    end 
    endtask  
integer i;
    task doTheThing(input integer times); begin
        for(i=0; i<times; i=i+1)begin
            tickTock;
        end   
    end
    endtask


    task reset; begin
        rst = 1;
        tickTock;
        rst = 0;
        tickTock;
        rst = 1;
        tickTock;
    end
    endtask

    task randKey;begin
        $display("\n              ** Generate Random 256-Key **");
        KEY[255:224] = $urandom%4294967295; #5; $write("%h",    KEY[255:224] );
        KEY[223:192] = $urandom%4294967295; #5; $write("%h_",   KEY[223:192] );
        KEY[191:160] = $urandom%4294967295; #5; $write("%h",    KEY[191:160] );
        KEY[159:128] = $urandom%4294967295; #5; $write("%h_",   KEY[159:128] );

        KEY[127: 96] = $urandom%4294967295; #5; $write("%h",    KEY[127: 96] );
        KEY[ 95: 64] = $urandom%4294967295; #5; $write("%h_",   KEY[ 95: 64] );
        KEY[ 63: 32] = $urandom%4294967295; #5; $write("%h",    KEY[ 63: 31] );
        KEY[ 31:  0] = $urandom%4294967295; #5; $write("%h\n",  
        KEY[ 31:  0] );
    end
    endtask

    task writeWord(input [7:0] address, input [31:0] word); begin
    if(DEBUG)$display("A: %h \nW: %h", address, word);
        cs         = 1;
        write_en   = 1;
        addr       = address;
        write_data = word;
        tickTock;
        cs         = 0;
        write_en   = 0;
    end
    endtask

    task loadKey(input [255:0] thisKey, input keyLen); begin
        $write("** LOAD KEY **");
        writeWord(ADDR_KEY0, thisKey[255:224]);
        writeWord(ADDR_KEY1, thisKey[223:192]);
        writeWord(ADDR_KEY2, thisKey[191:160]);
        writeWord(ADDR_KEY3, thisKey[159:128]);
        writeWord(ADDR_KEY4, thisKey[127: 96]);
        writeWord(ADDR_KEY5, thisKey[ 95: 64]);
        writeWord(ADDR_KEY6, thisKey[ 63: 32]);
        writeWord(ADDR_KEY7, thisKey[ 31:  0]);
        writeWord(ADDR_CONFIG, {28'h0000_000, 2'b0_0, keyLen, 1'b0});
        writeWord(ADDR_CTRL,   32'h0000_0001);
        doTheThing(15);
    end
    endtask

    task loadData(input [127:0] dataBlock, input keyLen, input encode ); begin
        $write("** LOAD DATA **");
        writeWord(ADDR_BLOCK0, dataBlock[127: 96]);
        writeWord(ADDR_BLOCK1, dataBlock[ 95: 64]);
        writeWord(ADDR_BLOCK2, dataBlock[ 63: 32]);
        writeWord(ADDR_BLOCK3, dataBlock[ 31:  0]);
        writeWord(ADDR_CONFIG, {28'h0000_00, 2'b00, keyLen, encode} );
        writeWord(ADDR_CTRL,   32'h0000_0002 );
        doTheThing(75);
    end
    endtask


    task readData(); begin
        $display("** READ DATA **");
        BUFFER   = 0;
        write_en = 0;
        cs       = 1;

        addr = ADDR_RESULT0;      tickTock;        
        BUFFER[127: 96] = read_data;
        addr = ADDR_RESULT1;      tickTock;        
        BUFFER[ 95: 64] = read_data;
        addr = ADDR_RESULT2;      tickTock;        
        BUFFER[ 63: 32] = read_data;
        addr = ADDR_RESULT3;      tickTock;       
        BUFFER[ 31:  0] = read_data;

        cs = 0;
    end
    endtask


    task testData(input [127:0] test); begin
        if(test != BUFFER) begin
            $display("ERROR: DATA MISMATCH");
            $display("Data: %h \nExp:  %h", BUFFER, test);
        end
        else $display("DATA MATCHES!!!   Clock cycles used:%3d", counter);
    end
    endtask


    task encryptData(input [127:0] data, input keyBits); begin
        counter = 0;
        
        //task loadKey(input thisKey [255:0], input keyLen); begin
        loadKey(KEY, keyBits);

        //task loadData(input dataBlock [127:0], keyLen, encode ); begin
        loadData(data, keyBits, 1);

        //task readData(); begin
        readData;
    end
    endtask

    task decrptyData(input [127:0] data, input keyBits); begin
        counter = 0;
        loadKey(KEY, keyBits);
        loadData(data, keyBits, 0);
        readData;                
    end
    endtask


    initial begin
    $display("********** Start AES Testbench **********");
        reset;
        encType = 1; // 256 encryption

    // Encrypt DATA1 with known key
        $display("\n******* Start 256-Key Known Ecyryption *******");

        //task encrptyData(input data [127:0], input keyBits); begin
        encryptData(DATA1, encType);

        //task testData(input test [127:0]); begin
        testData(EDATA);
        
    // Decrypt DATA1 with known key
        $display("******* Start Decyryption *******");
        decrptyData(BUFFER, encType);
        testData(DATA1);

        reset;
    // Encrypt DATA2 with known key
        $display("\n******* Start Known 256-Key Ecyryption *******");
        encryptData(DATA2, encType);
    // Decrypt DATA2 with known key
        $display("******* Start Decyryption *******");
        decrptyData(BUFFER, encType);
        testData(DATA2);


        reset;
        randKey;                        // generate random Key
    // Encrypt DATA2 with random key
        $display("\n******* Start Random 256-Key Ecyryption *******");
        encryptData(DATA2, encType);
    // Decrypt DATA2 with random key
        $display("******* Start Decyryption *******");
        decrptyData(BUFFER, encType);
        testData(DATA2);

        reset;
        randKey;                        // generate random Key
        encType = 0;
    // Encrypt DATA2 with random key
        $display("\n******* Start Random 128-Key Ecyryption *******");
        encryptData(DATA2, encType);
    // Decrypt DATA2 with random key
        $display("******* Start Decyryption *******");
        decrptyData(BUFFER, encType);
        testData(DATA2);


    $display("\n\n******** Complete AES Testbench ********");
    $stop;

        end
endmodule



                
/***************************************************** OLD ********              


                  parameter ADDR_CTRL        = 8'h08;
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
                5'h15: addr_out = ADDR_RESULT3;




                //read module info
                addr = 5'b0;
                bounce();
                addr = 5'b00001;
                bounce();
                addr = 5'b00010;
                bounce();
                

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
      

    
endmodule
  */

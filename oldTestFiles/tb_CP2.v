`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This is a testbench for the CP2 module being used. 
// -Key is set
// -start address written
// -Go and length are set
// -returned encrypted data tested
// -data decrypted and tested against original data
// -random key is generated
// -new data encrypted -> decrypted -> tested 
//////////////////////////////////////////////////////////////////////////////////


module tb_CP2();
    ////////////////// SETUP REG/WIRES //////////////////
    reg [255:0] KEY    = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF_FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    reg [127:0] DATA1  = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    reg [127:0] DATA2  = 128'h0123_4567_89ab_cdef_0123_4567_89ab_cdef;
    //Encrypted DATA
    reg [127:0] EDATA  = 128'hD5F93D6D3311CB309F23621B02FBD5E2;
    reg [127:0] BUFFER = 0;

    reg clk      = 1'b0;
    reg rst      = 1'b0;
    reg write_en = 1'b0;
    reg we_cpu   = 0;
    reg [5:0] addr_cpu;
    wire[19:0] addr_dma;
    reg go; 
    reg encode, bits;
    reg [31:0] wrData_dma = 0;
    wire [31:0] status, rdData_dma;
    reg [15:0] length = 0;
    
    wire INT;
    reg expHold, holdAck = 0;
    reg [19:0] startAddr, currentAddr = 0;
    reg  [ 5:0] addr       =  8'b0;
    reg  [31:0] write_data = 32'b0;
    wire [31:0] read_data;
    reg DEBUG = 0;   
    reg [31:0] wrData_cpu;
    wire [31:0] rdData_cpu;
    ////////////////// END SETUP REG/WIRES //////////////////
      
 CP2 dutCp2(
  .clk(clk), .rst(rst),     // input              clk, rst,
  .we_cpu     (we_cpu),     // input              we_cpu,
  .addr_cpu   (addr_cpu),   // input  wire [ 5:0] addr_cpu,
  .wrData_cpu (wrData_cpu), // input  wire [31:0] wrData_cpu,
  .rdData_cpu (rdData_cpu), // output wire [31:0] rdData_cpu,

  .we_dma     (we_dma),     // output reg        we_dma, 
  .addr_dma   (addr_dma),   // output reg [19:0] addr_dma, 
  .wrData_dma (wrData_dma), // input  wire[31:0] wrData_dma,
  .rdData_dma (rdData_dma), // output reg [31:0] rdData_dma,

  .HOLD_ACK    (holdAck),   // input         HOLD_ACK,
  .INT(INT), .HOLD(HOLD)    // output      INT, HOLD
  );
  
    assign status = {1'b0, go, bits, encode, 12'b0, length};

    integer counter  = 0;
    integer totalClk = 0;
  
    //move clock forward
    task tickTock;  begin
        #5;
        clk = 1;
        #5;
        clk = 0;
        counter = counter+1;
        totalClk = totalClk +1;
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
        rst = 0;
        tickTock;
        rst = 1;
        tickTock;
        rst = 0;
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
        KEY[ 63: 31] = $urandom%4294967295; #5; $write("%h",    KEY[ 63: 31] );
        KEY[ 31:  0] = $urandom%4294967295; #5; $write("%h\n",  
        KEY[ 31:  0] );
    end
    endtask

    task writeWord(input [7:0] address, input [31:0] word); begin
    if(DEBUG)$display("A: %h \nW: %h", address, word);
        we_cpu     = 1;
        addr_cpu   = address;
        wrData_cpu = word;
        tickTock;
        we_cpu     = 0;
    end
    endtask

    task loadKey(input [255:0] thisKey); begin
        $write("** LOAD KEY **");
        writeWord(2, thisKey[255:224]); 
        writeWord(3, thisKey[223:192]); 
        writeWord(4, thisKey[191:160]); 
        writeWord(5, thisKey[159:128]); 
        writeWord(6, thisKey[127: 96]); 
        writeWord(7, thisKey[ 95: 64]); 
        writeWord(8, thisKey[ 63: 32]); 
        writeWord(9, thisKey[ 31:  0]); 
    end
    endtask

    task loadData(input [127:0] data); begin
      $display("***Loading Data***");
      holdAck = 1;
      tickTock;         //Hold Ack

      testSig(1, 0, 0);
      testAddr(startAddr);
      wrData_dma = data[ 31:  0];
      tickTock;

      testAddr(currentAddr);
      wrData_dma = data[ 63: 32];
      tickTock;

      testAddr(currentAddr);
      wrData_dma = data[ 95: 64];
      tickTock;

      testAddr(currentAddr);
      wrData_dma = data[127: 96];
      tickTock;

      while(HOLD)tickTock;
      holdAck = 0;
    end
    endtask

    task unloadData; begin
      $display("***Unloading Data***");
      tickTock;        //dmaWaitA
      holdAck = 1;
      tickTock;        //dmaWaitB

      testSig(1, 0, 0);
      tickTock;        // dmaWriteA
      tickTock;
      testAddr(startAddr);
      BUFFER[ 31:  0] = rdData_dma;
      tickTock;

      testAddr(currentAddr);
      BUFFER[ 63: 32] = rdData_dma;
      tickTock;

      testAddr(currentAddr);
      BUFFER[ 95: 64] = rdData_dma;
      tickTock;

      testAddr(currentAddr);
      BUFFER[127: 96] = rdData_dma;
      tickTock;

      while(HOLD)tickTock;
      holdAck = 0;
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

    task testSig(input expHold, input expwedma, input expINT); begin
       if(HOLD != expHold) begin
            $display("ERROR: HOLD MISMATCH");
            $display("Data: %h \nExp:  %h", HOLD, expHold); end
       if(we_dma != expwedma) begin
            $display("ERROR: weDma MISMATCH");
            $display("Data: %h \nExp:  %h", we_dma, expwedma); end 
       if(INT != expINT) begin
            $display("ERROR: INT MISMATCH");
            $display("Data: %h \nExp:  %h", INT, expINT);   end  
    end
    endtask

    task testAddr(input [19:0] expAddr); begin
       if(addr_dma != expAddr) begin
            $display("ERROR: Addr MISMATCH");
            $display("Data: %h \nExp:  %h", addr_dma, expAddr); end 
       currentAddr = expAddr + 4;       
    end
    endtask

    task encryptData(input [127:0] data); begin
        writeWord(0, status);   // go
        tickTock;
        testSig(1, 0, 0);  //hold, we_dma, int

        counter = 0; 
      loadData(data); 
        $display("    Data loaded       -Counter: %d", counter );

        testSig(0, 0, 0);

        counter = 0;
      while(HOLD == 0)tickTock;
        $display("    Data Processed    -Counter: %d", counter );

        testSig(1, 0, 0);

        counter = 0;
      unloadData;
        $display("    Data Unloaded     -Counter: %d", counter );

        while(!INT)tickTock;
        testSig(0, 0, 1);
    end
    endtask


    always @ (counter)begin
      if(counter>200)begin
        $display("LOOPING ERROR");
        $stop;
      end
    end


    initial begin
    $display("********** Start AES Testbench **********");
    reset;
    // Encrypt DATA1 with known key
        $display("\n******* Start 256-Key Known Ecyryption *******");
        counter = 0;
        counter = 0;
        go      = 1;
        encode  = 1;
        bits    = 1;
        length  = 4;


        doTheThing(5);
        loadKey(KEY);
        $display("\nKey Loaded     -Counter: %d", counter );

        startAddr = 400;
        writeWord(1, startAddr);

        encryptData(DATA1);
        testData(EDATA);

        $display("\n******* Clear INT *******");
        writeWord(0, 32'h2000_0004 );


        $display("\n******* Start Decyryption *******");
        encode  = 0;
        doTheThing(5);

        encryptData(BUFFER);
        testData(DATA1);        
        $display("-----------------------------Total Clocks: %d", totalClk);

        //$display("\n******* Clear INT *******");
        writeWord(0, 32'h2000_0004 );




        $display("\n\n******* Start 256-Key Random Ecyryption *******");
        totalClk = 0;
        counter  = 0;
        encode  <= 1;

        randKey;
        doTheThing(5);
        loadKey(KEY);
        $display("\n    Key Loaded     -Counter: %d", counter );

        startAddr = 800;
        writeWord(1, startAddr);

        encryptData(DATA2);

        $display("\n******* Clear INT *******");
        writeWord(0, 32'h2000_0004 );

        $display("\n******* Start Decyryption *******");
        encode  = 0;
        doTheThing(5);

        encryptData(BUFFER);
        testData(DATA2);        
        $display("-----------------------------Total Clocks: %d", totalClk);


    $display("\n******** Complete CP2 Testbench ********");
    $stop;

        end
endmodule



                
module cp2_tb();

    
    //KEY
    reg [255:0] KEY = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    //NONCE
    reg [127:0] NONCE = 128'b0; 
    //DATA
    reg [127:0] DATA = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    //Encrypted DATA
    reg [127:0] EDATA = 128'hD5F93D6D3311CB309F23621B02FBD5E2;
    reg [127:0] BUFFER = 128'h00000000000000000000000000000000;
    
    //0
    //status
    //1-4 1 is lowest 4 is highest
    //nonce initial
    //5-12 5 is lowest 12 is highest
    //key in
    //13
    //data in
    //14
    //data out
    
    //status layout
    //status[0] = run, R/W
    //status[1] = rst, R/W
    //status[23] = ready, R/W
    //status31-24 = status flags, R
    //status 22 - 2 = 0;
    
    reg [3:0] addr = 4'b0;
    reg [31:0] din = 32'b0;
    wire int;
    reg we = 0;
    reg clk = 0;
    reg rst = 0;
    wire [31:0] dout;

    aes256_coprocessor u1 (.clock(clk), .addr(addr), .data_in(din), .write_en(we), .data_out(dout), .interrupt(int));



    initial begin
        addr = 4'b0000;
        //write 1 to everything except int and run
<<<<<<< HEAD:cp2_tb.v
        din = 32'hFF7FFFFE;
=======
        din = 32'hFF7F_FFFE;
>>>>>>> 14ab30ebc9f00b081770774e9eaf3278384f868c:depricated/cp2/cp2_tb.v
        we = 1;
        bounce();


        addr = 4'b0000;
        //write 1 to everything except int, run, and rst
        din = 32'hFF7F_FFFC;
        we = 1;
        bounce();


        
        addr = 4'b0000;
               
        
        //test that it was not written to
        //empty, full, empty, full, empty, full, empty, full, zero[22:2], reset, run
<<<<<<< HEAD:cp2_tb.v
        /*if(dout != {1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 21'b0, 1'b0, 1'b0})
            begin
                $display "Flag error";
                $stop;
            end
        */
=======
        //if(dout != {1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 21'b0, 1'b0, 1'b0})
        //    begin
        //        $display "Flag error";
        //        $stop;
        //    end
        
>>>>>>> 14ab30ebc9f00b081770774e9eaf3278384f868c:depricated/cp2/cp2_tb.v
        //test to see if we works
        
        
        
        
        
        //load nonce
        //word1
        addr = 4'b0001;
        din = NONCE[31:0];
        we = 1;
        bounce();
        //word2
        addr = 4'b0010;
        din = NONCE[63:32];
        we = 1;
        bounce();
        //word 3
        addr = 4'b0011;
        din = NONCE[95:64];
        we = 1;
        bounce();
        //word 4
        addr = 4'b0100;
        din = NONCE[127:96];
        we = 1;
        bounce();
        
        we = 0;
        bounce();
        
        //end of load NONCE
        
        //load key
        //5
        addr = 4'b0101;
        din = KEY[31:0];
        we = 1;
        bounce();
        //6
        addr = 4'b0110;
        din = KEY[63:32];
        we = 1;
        bounce();
        //7
        addr = 4'b0111;
        din = KEY[95:64];
        we = 1;
        bounce();
        //8
        addr = 4'b1000;
        din = KEY[127:96];
        we = 1;
        bounce();
        //9
        addr = 4'b1001;
        din = KEY[159:128];
        we = 1;
        bounce();
        //10
        addr = 4'b1010;
        din = KEY[191:160];
        we = 1;
        bounce();
        //11
        addr = 4'b1011;
        din = KEY[223:192];
        we = 1;
        bounce();
        //12
        addr = 4'b1100;
        din = KEY[255:224];
        we = 1;
        bounce();
        
        //end of load key
        
        //load data
        //loadData1
        addr=4'b1101;
        //din = DATA[31:0];
        din = 1;
        we = 1;
        bounce();
        //loadData2
        addr=4'b1101;
        //din = DATA[63:32];
        din = 2;
        we = 1;
        bounce();
        //loadData3
        addr=4'b1101;
        //din = DATA[95:64];
        din = 3;
        we = 1;
        bounce();
        //loadData4
        addr=4'b1101;
        //din = DATA[127:96];
        din = 4;
        we = 1;
        bounce();
        //end of load data
        
        
        //START TEST
        /*
                //load data
        //loadData1
        addr=4'b1101;
        din = DATA[31:0];
        we = 1;
        bounce();
        //loadData2
        addr=4'b1101;
        din = DATA[63:32];
        we = 1;
        bounce();
        //loadData3
        addr=4'b1101;
        din = DATA[95:64];
        we = 1;
        bounce();
        //loadData4
        addr=4'b1101;
        din = DATA[127:96];
        we = 1;
        bounce();
        //end of load data
        */
        //END TEST
        
        
        //status enable run
        addr = 4'b0000;
        din = 32'h00000001;
        we = 1;
        bounce();
        //running now
        we = 0;
        //encrypt data
        while(int != 1)
        begin
            bounce();
        end
        
        //check data output
        addr = 4'b1110;
        BUFFER[31:0] = dout;
        bounce();
        BUFFER[63:32] = dout;
        bounce();
        BUFFER[95:64] = dout;
        bounce();
        BUFFER[127:96] = dout;
        
        if(EDATA != BUFFER)
            begin
                $display("Data mismatch, encryption failed");
                $display ("Encrypted data");
                $display (EDATA);
                $display ("Actual output");
                $display (BUFFER);
                $stop;
            end
        
        //check decryption
        
        
        
        //load data
        //loadData1
        addr=4'b1101;
        din = BUFFER[31:0];
        we = 1;
        bounce();
        //loadData2
        addr=4'b1101;
        din = BUFFER[63:32];
        we = 1;
        bounce();
        //loadData3
        addr=4'b1101;
        din = BUFFER[95:64];
        we = 1;
        bounce();
        //loadData4
        addr=4'b1101;
        din = BUFFER[127:96];
        we = 1;
        bounce();
        //end of load data
        
        
       
        
        
        
        
        
        
        
        
        
        
        
        //status enable run
        addr = 4'b0000;
        din = 32'h00000001;
        we = 1;
        bounce();
        //running now
        we = 0;
        //encrypt data
        while(int != 1)
        begin
            bounce();
        end
        
        //check data output
        addr = 4'b1110;
        BUFFER[31:0] = dout;
        bounce();
        BUFFER[63:32] = dout;
        bounce();
        BUFFER[95:64] = dout;
        bounce();
        BUFFER[127:96] = dout;
        
        if(DATA != BUFFER)
            begin
                $display("Data mismatch, encryption failed");
                $display ("Encrypted data");
                $display (DATA);
                $display ("Actual output");
                $display (BUFFER);
                $stop;
            end
        
        
        $display("Test completed, unit validated");
        $stop;
        
        
    end

  
    
    
    
    //move clock forward
    task bounce;
        begin
            #5;
            clk = 1;
            #5;
            clk = 0;
            
        end
    endtask

endmodule
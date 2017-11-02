module tb_CPZero();

    reg         clk, rst, we1, alu_trap;
    reg  [ 4:0] addr;
    reg  [ 5:0] interrupt;
    reg  [31:0] wd, pcp4;

    wire        exl, iv;
    wire [31:0] rd1;
    reg  [31:0] exp_rd1;

    integer i, testNum, expOut, expExl, expIv;


// module CPzero 
// (input clk, rst, we1, alu_trap, [4:0] addr, [5:0] interrupt, [31:0] wd, pcp4,  
// output exl, iv, [31:0] rd1);
    CPzero cp(.clk (clk), 
             .rst (rst), 
             .we1 (we1), 
             .alu_trap(alu_trap),
             .addr(addr), 
             .interrupt(interrupt), 
             .wd  (wd),
             .pcp4(pcp4),
             .exl (exl),
             .iv  (iv), 
             .rd1 (rd1)
            );
     
    task tickTock; begin
        #5; clk = ~clk;
        #5; clk = ~clk;
        end
    endtask

    task reset; begin
        rst = 1; #5; 
        rst = 0; #5; 
        end
    endtask

    task enInt; begin
        addr = 12; we1 = 1; wd = 32'h0000_FF01;
        tickTock;
        we1 = 0;
    end
    endtask

    task disInt; begin
        addr = 12; we1 = 1; wd = 32'h0000_FF00;
        tickTock;
        we1 = 0;
    end
    endtask 

    task testOutput; begin
        $write("T:%2d ", testNum);
        if(rd1 != expOut)$write("\n     ERROR %2d: Out:%4h\n               Exp:%4h\n", testNum, rd1[15:0], expOut[15:0]);
        if(exl != expExl)$write("\n     ERROR %2d: Exl:%1d  Exp:%1d\n", testNum, exl, expExl);
        if(iv  !=  expIv)$write("\n     ERROR %2d:  IV:%1d  Exp:%1d\n", testNum,  iv,  expIv);
        testNum = testNum + 1;
    end
    endtask

    task test_alu_trap; begin
        testNum = 1;
        $display("*** alu_trap Start ***");
        addr = 12; we1 = 1; wd = 32'h0000_FFF1;
        expOut = 32'h0000_FF01;
        tickTock;
        we1 = 0;        
        testOutput;                      // test 1

        // alu_trap 
        // should trigger exl
        alu_trap = 1;             //set trap
        expExl   = 1; expOut = 32'h0000_FF03;    // should flag int
        tickTock;
        testOutput;                      // test 2
        
        alu_trap = 0;
        wd     = 32'h0000_FE02; we1 = 1;   // dis/clr reg
        expOut = 32'h0000_FE02; expExl = 1;
        tickTock;  
        we1 = 0;       
        testOutput;                      // test 3

        wd     = 32'h0000_FFFF; we1 = 1; 
        expOut = 32'h0000_FF01; expExl = 0;
        tickTock;         
        we1 = 0; 
        testOutput;                      // test 4
        $display("\n*** alu_trap Complete ***\n");
    end
    endtask

    // test that the read only bits cannot be written to from the CPU
    task test_13RO; begin
        reset;
        testNum = 1;
        $display("*** reg13 RO Start ***");
 
        addr = 13; we1  =  1; 
        wd     = 32'h0000_FAFF;
        expOut = 32'h0000_0028; expExl = 0; expIv = 0;
        tickTock;
        testOutput;                // test 1

        $display("\n*** reg13 RO Complete ***\n");
    end
    endtask



    // trigger int 5 and 0, test all process, validate RA(reg14) is correct
    task test_int5plus0; begin
        reset;
        testNum = 1;
        $display("*** int5/0 & RA(reg14) Start ***");
        enInt;

        //initilize
        addr = 13; we1 = 0; pcp4 = 32'h1234_ABCD;  interrupt = 0;
        expOut = 32'h0000_0028; expExl = 0; expIv = 0;    
        tickTock;     
        testOutput;                     // test 1

        //#5;//TEST TO REMOVE

        // hardware interrupt registers/flags exl async
        addr = 13; interrupt = 6'b1000_01;
        //#5;//TEST TO REMOVE
        expOut = 32'h0000_8428; expExl = 1; expIv = 0; 
        #5;            
        testOutput;                     // test 2

        // vector 13[6:2] set on neg clk edge
        tickTock; #5;
        expOut = 32'h0000_8400; expExl = 1; expIv = 0;             
        testOutput;                      // test 3

        // low interrupts does not clear flags
        interrupt = 0;
        tickTock;
        testOutput;                     // test 4

        // verify reg14 stored RA
        addr = 14; pcp4 = 0; expOut = 32'h1234_ABCD; 
        tickTock;
        testOutput;                     // test 5

        // int0 complete, flag cleared, exl still valied for int5
        addr = 12; wd = 32'h0000_FB02; we1 = 1;
        expOut = 32'h0000_FB02;
        tickTock; #5;
        testOutput;                     // test 6 
        addr = 13; we1 = 0; expOut = 32'h0000_8000;
        tickTock;
        testOutput;                     // test 7

        // int5 complete, all flags should clear including exl
        addr = 12; we1 = 1; wd = 32'h0000_7F02;
        expOut = 32'h0000_7F02;
        tickTock;
        testOutput;                     // test 8 
        addr = 13; we1 = 0;
        expOut = 32'h0000_0028; expExl = 0;
        tickTock;#5;
        testOutput;                     // test 9

        // reg14 RA is still valid at clocked address
        addr = 14; pcp4 = 0; expOut = 32'h1234_ABCD; 
        tickTock;
        testOutput;                      // test 10

        $display("\n*** int5/0 & RA(reg14) Complete ***\n");
    end
    endtask




/*
    task test_13RO; begin
        reset;
        testNum = 0;
        $display("*** Start ***");
        addr = 12; we1  =  1; 
        wd     = 32'h0000_FFF1;
        expOut = 32'h0000_FF01;
        tickTock;         
        testOutput;                      // test 1
        $display("\n***  Complete ***\n");
    end
    endtask
*/


    initial begin
        clk       = 0;
        rst       = 0;
        addr      = 0; 
        we1       = 0;
        alu_trap  = 0;
        interrupt = 0;
        wd        = 0; 
        pcp4      = 0;
        testNum   = 1;
        reset;

    // test initialized values
        $display("*** Initialize Start ***");
        expOut = 0;
        expExl = 0;
        expIv  = 0;
        reset;
        tickTock;
        
        addr = 12; #5;
        testOutput;                // test 1
        addr = 14; #5;
        testOutput;                // test 3
        addr = 13; #5; expOut = 32'h0000_0028;
        testOutput;                // test 2
        
        $display("\n*** Initialize Complete ***\n");

    // call test tasks
        test_alu_trap;
        test_13RO;
        test_int5plus0;





        $display("ALL COMPLETE");
        $stop;
    end

endmodule // END tb_CPZero
   

/*`timescale 1ns/10ps

module uart_tb();

reg clk, we;
reg [31:0] address, dataIn;
wire serial, o_Tx_Active, o_Tx_Done;
wire [7:0] w_Rx_Byte;

UARTser32to8 #(87) DUT1 (
    .clk(clk),
    .we(we),
    .address(address),
    .dataIn(dataIn),
    .serial(serial),
    .o_Tx_Active(o_Tx_Active),
    .o_Tx_Done(o_Tx_Done));

  uart_rx #(87) DUT2
    (.i_Clock(clk),
     .i_Rx_Serial(serial),
     .o_Rx_DV(),
     .o_Rx_Byte(w_Rx_Byte)
     );

initial begin
clk = 0;
we = 0;
address = 32'b0;
dataIn = 32'h12_34_56_78;
#5;



repeat(50)
    begin
    bounce();
    end

address = 32'hFFFF_FFFF;
we = 1;
bounce();
address = 32'h0;
we = 0;

repeat (10000)
    begin
    bounce();
    end;
    
    
clk = 0;
    we = 0;
    address = 32'b0;
    dataIn = 32'h12_34_56_78;
    #5;
    
    
    
    repeat(50)
        begin
        bounce();
        end
    
    address = 32'hFFFF_FFFF;
    we = 1;
    bounce();
    address = 32'h0;
    we = 0;
    
    repeat (10000)
        begin
        bounce();
        end;
        
    
    
$stop;


end


    //move clock forward
    task bounce;
        begin
            clk = 1;
            #5;
            clk = 0;
            #5;
        end
    endtask



endmodule


*/
//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
 
// This testbench will exercise both the UART Tx and Rx.
// It sends out byte 0xAB over the transmitter
// It then exercises the receive by receiving byte 0x3F
`timescale 1ns/10ps
 
`include "uart_tx.v"
`include "uart_rx.v"
 
module uart_tb ();
 
  // Testbench uses a 10 MHz clock
  // Want to interface to 115200 baud UART
  // 10000000 / 115200 = 87 Clocks Per Bit.
  parameter c_CLOCK_PERIOD_NS = 100;
  parameter c_CLKS_PER_BIT    = 87;
  parameter c_BIT_PERIOD      = 8600;
   
  reg r_Clock = 0;
  reg r_Tx_DV = 0;
  wire w_Tx_Done;
  reg [31:0] r_Tx_Byte = 0;
  reg r_Rx_Serial = 1;
  wire [7:0] w_Rx_Byte;
   
 
  // Takes in input byte and serializes it 
  task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer     ii;
    begin
       
      // Send Start Bit
      r_Rx_Serial <= 1'b0;
      #(c_BIT_PERIOD);
      #1000;
       
       
      // Send Data Byte
      for (ii=0; ii<8; ii=ii+1)
        begin
          r_Rx_Serial <= i_Data[ii];
          #(c_BIT_PERIOD);
        end
       
      // Send Stop Bit
      r_Rx_Serial <= 1'b1;
      #(c_BIT_PERIOD);
     end
  endtask // UART_WRITE_BYTE
   
  wire serial;
  uart_rx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_INST
    (.i_Clock(r_Clock),
     //.i_Rx_Serial(r_Rx_Serial),
     .i_Rx_Serial(serial),
     .o_Rx_DV(),
     .o_Rx_Byte(w_Rx_Byte)
     );
   
  uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_INST
    (.i_Clock(r_Clock),
     .i_Tx_DV(r_Tx_DV),
     .i_Tx_Byte(r_Tx_Byte),
     .o_Tx_Active(),
     .o_Tx_Serial(serial),
     .o_Tx_Done(w_Tx_Done)
     );
 
   
  always
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
 
   
  // Main Testing:
  initial
    begin
       
      // Tell UART to send a command (exercise Tx)
      @(posedge r_Clock);
      @(posedge r_Clock);
      r_Tx_DV <= 1'b1;
      //r_Tx_Byte <= 8'hAB;
      r_Tx_Byte <= 32'hFF_FF_FF_FE;
      @(posedge r_Clock);
      r_Tx_DV <= 1'b0;
      @(posedge w_Tx_Done);
       
      // Send a command to the UART (exercise Rx)
      //@(posedge r_Clock);
      //UART_WRITE_BYTE(8'h3F);
      //@(posedge r_Clock);
             
      // Check that the correct command was received
      //if (w_Rx_Byte == 8'h3F)
      //  $display("Test Passed - Correct Byte Received");
      //else
      //  $display("Test Failed - Incorrect Byte Received");
      $stop;
    end
   
endmodule
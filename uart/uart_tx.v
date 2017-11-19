//UART wrapper


module UARTser32to8
    #(parameter CLKS_PER_BIT = 87)
    (input clk,
    input we,
    input [31:0] address,
    input [31:0] dataIn,
    //output [7:0] dataOut,
    output serial,
    output o_Tx_Active,
    output o_Tx_Done
);

reg [31:0] tmp;
reg enable;

uart_tx #(CLKS_PER_BIT) tx1 (.i_Clock(clk), 
    .i_Tx_DV(enable), .i_Tx_Byte(tmp), .o_Tx_Active(o_Tx_Active), 
    .o_Tx_Serial(serial), .o_Tx_Done(o_Tx_Done));

// count: 0, 1, 2, 3, 0, ... (wraps automatically)
reg [2:0] count = 0;
//add once a byte has been sent out
always @(posedge o_Tx_Done) begin
    if(count < 3'd4)
        count <= count + 2'd1;
    else
        count <= 3'b000;
end


always @(posedge clk) begin
    if (count == 3'd0 && we == 1 && address == 32'hFFFF_FFFF)
        begin
            tmp <= dataIn;
            enable <= 1'b1;
        end
    else if(o_Tx_Active != 1)
        tmp <= (tmp >> 8);
        
    if(count >= 4)
        begin
            enable <= 1'b0;
        end
end

//assign dataOut = tmp[7:0];

endmodule



//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Transmitter.  This transmitter is able
// to transmit 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When transmit is complete o_Tx_done will be
// driven high for one clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
module uart_tx 
  #(parameter CLKS_PER_BIT = 87)
  (
   input       i_Clock,
   input       i_Tx_DV,
   //input [7:0] i_Tx_Byte, 
   input [31:0] i_Tx_Byte,
   output      o_Tx_Active,
   output reg  o_Tx_Serial,
   output      o_Tx_Done
   );
  
  parameter s_IDLE         = 3'b000;
  parameter s_TX_START_BIT = 3'b001;
  parameter s_TX_DATA_BITS = 3'b010;
  parameter s_TX_STOP_BIT  = 3'b011;
  parameter s_CLEANUP      = 3'b100;
   
  reg [2:0]    r_SM_Main     = 0;
  reg [31:0]   r_Clock_Count = 0;
  reg [5:0]    r_Bit_Index   = 0;
  reg [31:0]   r_Tx_Data     = 0;
  reg          r_Tx_Done     = 0;
  reg          r_Tx_Active   = 0;
     
  always @(posedge i_Clock)
    begin
       
      case (r_SM_Main)
        s_IDLE :
          begin
            o_Tx_Serial   <= 1'b1;         // Drive Line High for Idle
            r_Tx_Done     <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (i_Tx_DV == 1'b1)
              begin
                r_Tx_Active <= 1'b1;
                r_Tx_Data   <= i_Tx_Byte;
                r_SM_Main   <= s_TX_START_BIT;
              end
            else
              r_SM_Main <= s_IDLE;
          end // case: s_IDLE
         
         
        // Send out Start Bit. Start bit = 0
        s_TX_START_BIT :
          begin
            o_Tx_Serial <= 1'b0;
             
            // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_START_BIT;
              end
            else
              begin
                r_Clock_Count <= 0;
                r_SM_Main     <= s_TX_DATA_BITS;
              end
          end // case: s_TX_START_BIT
         
         
        // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
        s_TX_DATA_BITS :
          begin
            o_Tx_Serial <= r_Tx_Data[r_Bit_Index];
             
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count <= 0;
                 
                // Check if we have sent out all bits
                if (r_Bit_Index < 31)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= s_TX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_TX_STOP_BIT;
                  end
              end
          end // case: s_TX_DATA_BITS
         
         
        // Send out Stop bit.  Stop bit = 1
        s_TX_STOP_BIT :
          begin
            o_Tx_Serial <= 1'b1;
             
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_STOP_BIT;
              end
            else
              begin
                r_Tx_Done     <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
                r_Tx_Active   <= 1'b0;
              end
          end // case: s_Tx_STOP_BIT
         
         
        // Stay here 1 clock
        s_CLEANUP :
          begin
            r_Tx_Done <= 1'b1;
            r_SM_Main <= s_IDLE;
          end
         
         
        default :
          r_SM_Main <= s_IDLE;
         
      endcase
    end
 
  assign o_Tx_Active = r_Tx_Active;
  assign o_Tx_Done   = r_Tx_Done;
   
endmodule
`timescale 1ns/1ps
module uart_top(input RClk, input clk, input reset, input we, input [31:0] dataIn, address, output serial);

wire write = ((we == 1'b1) && (address == 32'h0000_7000)) ? 1:0;
wire [31:0] toUart;
wire busy;
wire Empty_out;
wire pNextWordToRead;
reg [2:0] counter;
wire [7:0] data;

aFifo uart_fifo(.RClk(RClk), .WClk(clk), .Clear_in(reset), .Data_in(dataIn), .Data_out(toUart), .WriteEn_in(((we == 1'b1) & (address == 32'h0000_7000))), .ReadEn_in((counter >= 3'b100) && (!Empty_out)), .Empty_out(Empty_out), .pNextWordToRead(pNextWordToRead));

//UART_TX_CTRL UART1 (.SEND((busy) && (!Empty_out)), .DATA(toUart[7:0]), .CLK(clk), .READY(busy), .UART_TX(serial));

/*
entity UART_TX_CTRL is
    Port ( SEND : in  STD_LOGIC;
           DATA : in  STD_LOGIC_VECTOR (7 downto 0);
           CLK : in  STD_LOGIC;
           READY : out  STD_LOGIC;
           UART_TX : out  STD_LOGIC);*/


uart UART1 (.clk(clk), .reset_n(~reset), 
    .tx_ena((~busy) & (~Empty_out) & (pNextWordToRead >= 1'b0)), .tx_data(data), 
    .rx(1'b1), .rx_busy(), 
    .rx_error(), .rx_data(), 
    .tx_busy(busy), .tx(serial));

shifter SHIFT(.selector(counter), .word(toUart), .byte(data));
    
always @ (posedge clk, posedge reset)
begin
    if(reset)
        begin
        counter = 0;
        end
    else if(counter >= 3'b100) begin
                    counter = 0;
            end
    else if(!Empty_out && !busy) begin
        counter = counter + 1;
    end

    
end    
    
   
endmodule


module shifter(input /*shift,*/ [1:0] selector, input [31:0] word, output [7:0] byte);

    //wire [31:0] temp;
    //reg [1:0] counter;
    mux4 #(8) select (.a(word[31:24]), .b(word[23:16]), .c(word[15:8]), .d(word[7:0]), .sel(selector), .y(byte));


endmodule




module aFifo
  #(parameter    DATA_WIDTH    = 32,
                 ADDRESS_WIDTH = 6,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
     //Reading port
    (//output reg  [DATA_WIDTH-1:0]        Data_out,
     output wire  [DATA_WIDTH-1:0]        Data_out,
     output wire  [ADDRESS_WIDTH-1:0]    pNextWordToRead, 
     output reg                          Empty_out,
     input wire                          ReadEn_in,
     input wire                          RClk,        
     //Writing port.	 
     input wire  [DATA_WIDTH-1:0]        Data_in,  
     output reg                          Full_out,
     input wire                          WriteEn_in,
     input wire                          WClk,
	 
     input wire                          Clear_in);

    /////Internal connections & variables//////
    reg   [DATA_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];
    wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite;
    wire                                EqualAddresses;
    wire                                NextWriteAddressEn, NextReadAddressEn;
    wire                                Set_Status, Rst_Status;
    reg                                 Status;
    wire                                PresetFull, PresetEmpty;
    
    //////////////Code///////////////
    //Data ports logic:
    //(Uses a dual-port RAM).
    //'Data_out' logic:
    //always @ (posedge RClk)
    //    if (ReadEn_in & !Empty_out)
    //        Data_out <= Mem[pNextWordToRead];
    assign Data_out = (!Empty_out) ? Mem[pNextWordToRead] : Mem[pNextWordToRead];       
            
    //'Data_in' logic:
    always @ (posedge WClk)
        if (WriteEn_in & !Full_out)
            Mem[pNextWordToWrite] <= Data_in;

    //Fifo addresses support logic: 
    //'Next Addresses' enable logic:
    assign NextWriteAddressEn = WriteEn_in & ~Full_out;
    assign NextReadAddressEn  = ReadEn_in  & ~Empty_out;
           
    //Addreses (Gray counters) logic:
    GrayCounter GrayCounter_pWr
       (.GrayCount_out(pNextWordToWrite),
       
        .Enable_in(NextWriteAddressEn),
        .Clear_in(Clear_in),
        
        .Clk(WClk)
       );
       
    GrayCounter GrayCounter_pRd
       (.GrayCount_out(pNextWordToRead),
        .Enable_in(NextReadAddressEn),
        .Clear_in(Clear_in),
        .Clk(RClk)
       );
     

    //'EqualAddresses' logic:
    assign EqualAddresses = (pNextWordToWrite == pNextWordToRead);

    //'Quadrant selectors' logic:
    assign Set_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ~^ pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ^  pNextWordToRead[ADDRESS_WIDTH-2]);
                            
    assign Rst_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ^  pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ~^ pNextWordToRead[ADDRESS_WIDTH-2]);
                         
    //'Status' latch logic:
    always @ (Set_Status, Rst_Status, Clear_in) //D Latch w/ Asynchronous Clear & Preset.
        if (Rst_Status | Clear_in)
            Status = 0;  //Going 'Empty'.
        else if (Set_Status)
            Status = 1;  //Going 'Full'.
            
    //'Full_out' logic for the writing port:
    assign PresetFull = Status & EqualAddresses;  //'Full' Fifo.
    
    always @ (posedge WClk, posedge PresetFull) //D Flip-Flop w/ Asynchronous Preset.
        if (PresetFull)
            Full_out <= 1;
        else
            Full_out <= 0;
            
    //'Empty_out' logic for the reading port:
    assign PresetEmpty = ~Status & EqualAddresses;  //'Empty' Fifo.
    
    always @ (posedge RClk, posedge PresetEmpty)  //D Flip-Flop w/ Asynchronous Preset.
        if (PresetEmpty)
            Empty_out <= 1;
        else
            Empty_out <= 0;
            
endmodule





module GrayCounter
   #(parameter   COUNTER_WIDTH = 6)
   
    (output reg  [COUNTER_WIDTH-1:0]    GrayCount_out,  //'Gray' code count output.
    
     input wire                         Enable_in,  //Count enable.
     input wire                         Clear_in,   //Count reset.
    
     input wire                         Clk);

    /////////Internal connections & variables///////
    reg    [COUNTER_WIDTH-1:0]         BinaryCount;

    /////////Code///////////////////////
    
    always @ (posedge Clk)
        if (Clear_in) begin
            BinaryCount   <= {COUNTER_WIDTH{1'b 0}} + 1;  //Gray count begins @ '1' with
            GrayCount_out <= {COUNTER_WIDTH{1'b 0}};      // first 'Enable_in'.
        end
        else if (Enable_in) begin
            BinaryCount   <= BinaryCount + 1;
            GrayCount_out <= {BinaryCount[COUNTER_WIDTH-1],
                              BinaryCount[COUNTER_WIDTH-2:0] ^ BinaryCount[COUNTER_WIDTH-1:1]};
        end
    
endmodule
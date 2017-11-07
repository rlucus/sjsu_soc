module timer #(parameter KHZ = 5, NANOSEC = 1000) 
(input fastclk, slowclk, output out);

    localparam 
        TICKS = 100;
    reg [31:0] accum = TICKS;
    reg signal = 0;
    reg reset = 0;
    
    assign out = signal;
    
    always @(posedge fastclk) begin
        accum <= (signal ? TICKS : accum) - 1;
        signal = (accum == 0) ? 1 : signal;
    end
    
    always @(posedge slowclk) begin
        if (reset) begin
            signal = 0;
            reset = 0;
        end else if (signal) begin
            reset = 1;
        end
    end
endmodule

//
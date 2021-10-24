module Debouncer(clk, in, out);
    parameter frequency = 12_000_000;
    parameter waitTime = 0.05;

    localparam waitTicks = $rtoi(waitTime * frequency);

    input wire clk;
    input wire in;
    output reg [1 : 0] out;
    
    reg lastState = 0;
    reg [$clog2(waitTicks) - 1 : 0] counter = 0;
    
    always @(posedge clk) 
    begin
        if (lastState == in)
        begin
            counter <= (counter == waitTicks) ? waitTicks : counter + 1;
            out <= 0;
        end
        else
        begin
            counter <= 0;

            if (counter == waitTicks)
            begin
                lastState <= in;
                out <= (in == 1) ? 1 : 2;
            end
            else
                out <= 0;
        end
    end
endmodule

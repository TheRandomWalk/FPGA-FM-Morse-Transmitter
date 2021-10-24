module Top(clk, btn, rgb, led, rf);
    localparam waitTime = 0.05;

    localparam rfPhaseBits   = 28;
    localparam basePhaseBits = 28;
    localparam lutBits       = 6;
    localparam sinCosBits    = 16;

    localparam frequencySlow =  60_000_000.0;
    localparam frequencyFast = 240_000_000.0;
    localparam frequencyTx   = 106_100_000.0;
    localparam testTone      =         750.0;

    input  wire clk;   
    input  wire [ 1 : 0] btn;
    output wire [ 2 : 0] rgb;
    output wire [ 3 : 0] led;
    output wire [31 : 0] rf;
       
    reg reset = 0;
    wire locked;

    clockWizard clockWizard(.clk(clk), .reset(reset), .clkSlow(clkSlow), .clkFast(clkFast), .locked(locked));

    wire [1 : 0] pressState;

    Debouncer #(.frequency(frequencySlow), .waitTime(waitTime)) debouncer(clkSlow, btn[1], pressState);

    reg rfOutput = 0;
    
    always @(posedge clkSlow) 
        if (pressState == 1)
            rfOutput = ~rfOutput;

    assign led = rfOutput ? 4'b1111 : 4'b0; 

    wire rfOut;

    FmTx #
    (
        .frequencySlow(frequencySlow), 
        .frequencyFast(frequencyFast),
        .frequencyTx(frequencyTx),
        .testTone(testTone),
        .rfPhaseBits(rfPhaseBits),
        .basePhaseBits(basePhaseBits),
        .lutBits(lutBits),
        .sinCosBits(sinCosBits)
    ) 
    fmTx (clkSlow, clkFast, btn[0], rfOut);
     
    assign rf = rfOutput ? {32{rfOut}} : 32'b0;
    assign rgb = {3{~(rfOutput & btn[0])}};
endmodule

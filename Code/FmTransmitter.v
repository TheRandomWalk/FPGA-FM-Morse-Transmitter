module FmTx(clkSlow, clkFast, enable, rf);
    parameter frequencySlow =  60_000_000.0;
    parameter frequencyFast = 240_000_000.0;
    parameter frequencyTx   = 106_500_000.0;
    parameter testTone      =         750.0;

    parameter rfPhaseBits   = 32;
    parameter basePhaseBits = 24;
    parameter lutBits       = 6;
    parameter sinCosBits    = 16;
    
    input wire clkSlow;   
    input wire clkFast;   
    input wire enable;
    output reg rf = 0;
    
    localparam [rfPhaseBits   - 1 : 0] dRfPhaseCarrier = (2.0 ** rfPhaseBits  ) / frequencyFast * frequencyTx;
    localparam [basePhaseBits - 1 : 0] dBasePhase      = (2.0 ** basePhaseBits) / frequencySlow * testTone;
    
    reg  [rfPhaseBits   - 1 : 0] dTemp = 0;

    reg  [rfPhaseBits   - 1 : 0] dRfPhase  = 0;
    reg  [rfPhaseBits   - 1 : 0] rfPhase   = 0;
    reg  [basePhaseBits - 1 : 0] basePhase = 0;
    wire signed [sinCosBits - 1 : 0] sin;
    wire signed [sinCosBits - 1 : 0] cos;
    
    SinCosUnsigned #(basePhaseBits, lutBits, sinCosBits) sinCosUnsigned(clkSlow, basePhase, sin, cos);
    
    always @(posedge clkFast) 
    begin
        rfPhase <= rfPhase + dRfPhase;
        rf <= rfPhase[rfPhaseBits - 1];
    end

    always @(posedge clkSlow) 
    begin
        basePhase <= basePhase + dBasePhase;
        dTemp <= enable ? dRfPhaseCarrier - (1 << (sinCosBits )) + (sin << 1) : dRfPhaseCarrier;
        dRfPhase <= dTemp;
    end
endmodule

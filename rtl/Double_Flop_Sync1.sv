`timescale 1ns / 1ps
`include "param.sv"

module Double_Flop_Sync1(
    input  logic wclk,
    input  logic wrst,
    input  logic [`ADDR_WIDTH:0] rptr,
    output logic [`ADDR_WIDTH:0] rptr_sync_wclk
    );
    
    logic [`ADDR_WIDTH:0] q1;
    
    always_ff@ (posedge wclk or posedge wrst) begin
        if(wrst)
            {rptr_sync_wclk, q1} <= 0;
        else
            {rptr_sync_wclk, q1} <= {q1, rptr};
    end
    
endmodule

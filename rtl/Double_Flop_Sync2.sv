`timescale 1ns / 1ps
`include "param.sv"

module Double_Flop_Sync2(
    input  logic rclk,
    input  logic rrst,
    input  logic [`ADDR_WIDTH:0] wptr,
    output logic [`ADDR_WIDTH:0] wptr_sync_rclk
    );
    
    logic [`ADDR_WIDTH:0] q2;
    
    always_ff@ (posedge rclk or posedge rrst) begin
        if(rrst)
            {wptr_sync_rclk, q2} <= 0;
        else
            {wptr_sync_rclk, q2} <= {q2, wptr};
    end
    
endmodule


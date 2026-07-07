`timescale 1ns / 1ps
`include "param.sv"

module Read_Handler(
    input  logic rclk,
    input  logic rrst,
    input  logic rd_en,
    input  logic [`ADDR_WIDTH:0]   wptr_sync_rclk,
    output logic [`ADDR_WIDTH-1:0] raddr,
    output logic [`ADDR_WIDTH:0]   rptr,
    output logic empty
    );
    
    logic [`ADDR_WIDTH:0] rptr_bin;
    logic [`ADDR_WIDTH:0] rptr_bin_next, rptr_next;
    
    assign raddr         = rptr_bin[`ADDR_WIDTH-1:0];
    assign rptr_bin_next =  rptr_bin + (rd_en & !empty);
    assign rptr_next     = (rptr_bin_next >> 1)^rptr_bin_next;
    
    
    always_ff@ (posedge rclk or posedge rrst) begin
        if(rrst)
            {rptr, rptr_bin} <= 0;
        else
            {rptr, rptr_bin} <= {rptr_next, rptr_bin_next};
    end
    
    always_ff@ (posedge rclk or posedge rrst) begin
        if(rrst)
            empty <= 1;
        else
            empty <= (wptr_sync_rclk == rptr_next);
    end
    
endmodule

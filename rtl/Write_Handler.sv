`timescale 1ns / 1ps
`include "param.sv"

module Write_Handler(
    input  logic wclk, 
    input  logic wrst,
    input  logic wr_en,
    input  logic [`ADDR_WIDTH:0]   rptr_sync_wclk,
    output logic [`ADDR_WIDTH-1:0] waddr,
    output logic [`ADDR_WIDTH:0] wptr,
    output logic full    
    );
    
    logic [`ADDR_WIDTH:0] wptr_bin;
    logic [`ADDR_WIDTH:0] wptr_bin_next, wptr_next;
    
    assign waddr         = wptr_bin[`ADDR_WIDTH-1:0];
    assign wptr_bin_next =  wptr_bin + (wr_en & !full);
    assign wptr_next     = (wptr_bin_next >> 1)^wptr_bin_next;
    
    always_ff@ (posedge wclk or posedge wrst) begin
        if(wrst)
            {wptr, wptr_bin} <= 0;
        else
            {wptr, wptr_bin} <= {wptr_next, wptr_bin_next};
    end
    
    always_ff@ (posedge wclk or posedge wrst) begin
        if(wrst)
            full <= 0;
        else
            full <= (wptr_next == {~rptr_sync_wclk[`ADDR_WIDTH:`ADDR_WIDTH-1], 
                                    rptr_sync_wclk[`ADDR_WIDTH-2:0]});
    end
    
endmodule

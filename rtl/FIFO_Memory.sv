`timescale 1ns / 1ps
`include "param.sv"

module FIFO_Memory (
    input  logic wclk,                      // write clock
    input  logic wr_en,                     // write clock enable
    input  logic full,                      // write full
    input  logic [`ADDR_WIDTH-1:0] waddr,   // write address  
    input  logic [`ADDR_WIDTH-1:0] raddr,   // read address
    input  logic [`DATA_WIDTH-1:0] wdata,   // Input data - data to be written
    output logic [`DATA_WIDTH-1:0] rdata    // Output data - data to be read
    );

    localparam DEPTH = 1<<`ADDR_WIDTH;        // Depth of the FIFO memory
    logic [`DATA_WIDTH-1:0] mem [0:DEPTH-1];  // FIFO Memory 

    assign rdata = mem[raddr];    // Read data

    always_ff @(posedge wclk) begin
        if (wr_en && !full) 
            mem[waddr] <= wdata;  // Write data
    end
endmodule

`timescale 1ns / 1ps
`include "param.sv"

module testbench;
    logic  wclk, wrst, wr_en;
    logic  rclk, rrst, rd_en;
    logic  [`DATA_WIDTH-1:0] wdata;
    logic  [`DATA_WIDTH-1:0] rdata;
    logic  empty, full;
    
    localparam DEPTH = 1<<`ADDR_WIDTH;
    
    Async_FIFO_top FIFO (.wclk(wclk), 
                         .wrst(wrst), 
                         .wr_en(wr_en), 
                         .rclk(rclk), 
                         .rrst(rrst),
                         .rd_en(rd_en), 
                         .wdata(wdata), 
                         .rdata(rdata), 
                         .empty(empty), 
                         .full(full)
                         );
    
    always #5  wclk = ~wclk;    // faster writing
    always #8 rclk  = ~rclk;   // slower reading
    
    
    initial begin
        {wclk,  wr_en, rclk, rd_en} = 0;
        wrst = 1; rrst = 1;
        #15 wrst = 0; rrst = 0;
        
        //Writing into FIFO beyond full 
        @(negedge wclk); wdata = 8'hA0; wr_en = 1;
        @(negedge wclk); wdata = 8'hA1;
        @(negedge wclk); wdata = 8'hA2;
        @(negedge wclk); wdata = 8'hA3;
        @(negedge wclk); wdata = 8'hA4;
        @(negedge wclk); wdata = 8'hA5;
        @(negedge wclk); wdata = 8'hA6;
        @(negedge wclk); wdata = 8'hA7;
        @(negedge wclk); wdata = 8'h44;
        @(negedge wclk); wdata = 8'h55;
        @(negedge wclk); wdata = 8'h66;
        @(negedge wclk); wdata = 8'h00; wr_en = 0;
        
        // Reading from FIFO below empty
        @(negedge rclk); rd_en = 1;
        repeat(10) @(negedge rclk); rd_en = 0;
        #10 $finish;
        
    end
    
endmodule
`timescale 1ns / 1ps
`include "param.sv"

module Async_FIFO_top(
    input  logic wclk, wrst, wr_en,
    input  logic rclk, rrst, rd_en,
    input  logic [`DATA_WIDTH-1:0] wdata,
    output logic [`DATA_WIDTH-1:0] rdata,
    output logic empty, full
    );
    
    logic [`ADDR_WIDTH-1:0] raddr, waddr;
    logic [`ADDR_WIDTH:0]   rptr, wptr;
    logic [`ADDR_WIDTH:0]   rptr_sync_wclk, wptr_sync_rclk;
    
    FIFO_Memory  FMem  (.wclk(wclk),
                        .wr_en(wr_en),
                        .full(full), 
                        .waddr(waddr), 
                        .raddr(raddr), 
                        .wdata(wdata), 
                        .rdata(rdata)
                        );
    
    
    Write_Handler  WH   (.wclk(wclk),
                         .wrst(wrst), 
                         .wr_en(wr_en), 
                         .rptr_sync_wclk(rptr_sync_wclk), 
                         .waddr(waddr), 
                         .wptr(wptr), 
                         .full(full)
                         );
    
    Double_Flop_Sync1  DFS1 (.wclk(wclk), 
                             .wrst(wrst),
                             .rptr(rptr),  
                             .rptr_sync_wclk(rptr_sync_wclk)
                             );
    
    Read_Handler  RH  (.rclk(rclk), 
                       .rrst(rrst), 
                       .rd_en(rd_en),
                       .wptr_sync_rclk(wptr_sync_rclk), 
                       .raddr(raddr), 
                       .rptr(rptr), 
                       .empty(empty)
                       );
                          
    Double_Flop_Sync2  DFS2  (.rclk(rclk), 
                              .rrst(rrst), 
                              .wptr(wptr),  
                              .wptr_sync_rclk(wptr_sync_rclk)
                              );
    
endmodule

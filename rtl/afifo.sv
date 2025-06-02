`timescale 1ns / 1ps

module afifo #(
    parameter DATA_WIDTH = 32
) (
    input logic clk_w, clk_r,
    input logic arst,
    input logic we_i, re_i,
    input logic [DATA_WIDTH-1:0] data_w,
    output logic [DATA_WIDTH-1:0] data_r,
    output logic full, empty
);
    localparam DEPTH = 8;
    localparam PTR_WIDTH = $clog2(DEPTH);

    logic [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;
    logic [PTR_WIDTH:0] b_wptr, b_rptr;
    logic [PTR_WIDTH:0] g_wptr, g_rptr;

    logic [PTR_WIDTH-1:0] waddr, raddr;

    //write pointer to read clock domain
    synchronizer #(PTR_WIDTH) sync_wptr (
        .*,
        .clk(clk_r),
        .d_in(g_wptr),
        .d_out(g_wptr_sync)
    );
    //read pointer to write clock domain 
    synchronizer #(PTR_WIDTH) sync_rptr (
        .*,
        .clk(clk_w),
        .d_in(g_rptr),
        .d_out(g_rptr_sync)
    );

    wptr_handler #(PTR_WIDTH) wptr_h(
        .*,
        .w_en(we_i)
    );

    rptr_handler #(PTR_WIDTH) rptr_h(
        .*,
        .r_en(re_i)
    );

    fifo_mem #(DATA_WIDTH, DEPTH) fifo_mem(
        .*,
        .w_en(we_i),
        .r_en(re_i),
        .data_in(data_w),
        .data_out(data_r)
    );

endmodule
`timescale 1ns / 1ps

module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8,
    localparam PTR_WIDTH = $clog2(DEPTH)
) (
    input logic clk_w, clk_r, arst,
    input logic w_en, r_en,
    input logic [PTR_WIDTH:0] b_wptr, b_rptr,
    input logic [DATA_WIDTH-1:0] data_in,
    input logic full, empty,
    output logic [DATA_WIDTH-1:0] data_out
);
    logic [DATA_WIDTH-1:0] fifo[0:DEPTH-1];

    always_ff @ (posedge clk_w) begin
        if(w_en & !full) begin
            fifo[b_wptr[PTR_WIDTH-1:0]] <= data_in;
        end
    end
    /*
    always@(posedge clk_r) begin
    if(r_en & !empty) begin
        data_out <= fifo[b_rptr[PTR_WIDTH-1:0]];
    end
    end
    */
    assign data_out = (arst) ? 0 : fifo[b_rptr[PTR_WIDTH-1:0]];
endmodule
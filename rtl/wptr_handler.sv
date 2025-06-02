`timescale 1ns / 1ps

module wptr_handler #(
    parameter PTR_WIDTH=3
) (
    input logic clk_w, arst, w_en,
    input logic [PTR_WIDTH:0] g_rptr_sync,
    output logic [PTR_WIDTH:0] b_wptr, g_wptr,
    output logic full
);
    logic [PTR_WIDTH:0] b_wptr_next;
    logic [PTR_WIDTH:0] g_wptr_next;

    logic wrap_around;
    logic wfull;

    assign b_wptr_next = b_wptr + {{3'b0}, {(w_en & !full)}};
    assign g_wptr_next = (b_wptr_next >>1)^b_wptr_next;

    always_ff @ (posedge clk_w or posedge arst) begin
        if(arst) begin
            b_wptr <= 0; // set default value
            g_wptr <= 0;
        end
        else begin
            b_wptr <= b_wptr_next; // incr binary write pointer
            g_wptr <= g_wptr_next; // incr gray write pointer
        end
    end

    always_ff @ (posedge clk_w or posedge arst) begin
        full <= (arst) ? 0 : wfull;
    end

    assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});
endmodule

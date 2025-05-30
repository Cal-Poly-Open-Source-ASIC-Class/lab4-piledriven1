`timescale 1ns / 1ps

module rptr_handler #(
    parameter PTR_WIDTH=3
) (
    input logic clk_r, arst, r_en,
    input logic [PTR_WIDTH:0] g_wptr_sync,
    output logic [PTR_WIDTH:0] b_rptr, g_rptr,
    output logic empty
);
    logic [PTR_WIDTH:0] b_rptr_next;
    logic [PTR_WIDTH:0] g_rptr_next;
    logic rempty;

    assign b_rptr_next = b_rptr + { {3'b0}, {(r_en & !empty)} };
    assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;
    assign rempty = (g_wptr_sync == g_rptr_next);
    
    always@(posedge clk_r or posedge arst) begin
        if(arst) begin
            b_rptr <= 0;
            g_rptr <= 0;
        end
        else begin
            b_rptr <= b_rptr_next;
            g_rptr <= g_rptr_next;
        end
    end
    
    always@(posedge clk_r or posedge arst) begin
        if(!arst) empty <= 1;
        else        empty <= rempty;
    end
endmodule

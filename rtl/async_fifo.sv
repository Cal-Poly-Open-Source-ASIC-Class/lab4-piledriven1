`timescale 1ns / 1ps

module async_fifo #(
    parameter DATA_WIDTH = 32
) (
    input logic clk_r, clk_w, arst,
    input logic we_i, re_i,
    input logic [DATA_WIDTH - 1:0] data_r,
    output logic empty_o, full_o,
    output logic [DATA_WIDTH - 1:0] data_w
);
    logic [DATA_WIDTH - 1:0] data_ff;

    // 2-stage clock synchronizer
    always_ff @ (posedge clk_r or negedge arst) begin
        if(arst) begin
            full_o <= 0;
            data_ff <= 0;
        end
        else begin
            if(re_i && empty_o) begin
                data_ff <= data_r;
                full_o <= 0;
            end
            else if(re_i && !empty_o) begin
                data_ff <= data_r;
                full_o <= 1;
            end
            else begin
                data_ff <= 0;
                full_o <= (data_ff != 0) ? 1 : 0;
            end
        end
    end

    always_ff @(posedge clk_w or negedge arst) begin
        if(arst) begin
            empty_o <= 1;
            data_w <= 0;
        end
        else begin
            if(we_i && full_o) begin
                data_w <= data_ff;
                empty_o <= 0;
            end
            else if(we_i && !full_o) begin
                data_w <= data_ff;
                empty_o <= 0;
            end
            else begin
                data_w <= 0;
                empty_o <= (data_ff != 0) ? 0 : 1;
            end
        end
    end
endmodule
